using System;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                var dbHost = GetEnvironmentVariable("DB_HOST", "db");
                var dbPort = int.Parse(
                    GetEnvironmentVariable("DB_PORT", "5432")
                );
                var dbName = GetEnvironmentVariable(
                    "DB_NAME",
                    "postgres"
                );
                var dbUser = GetEnvironmentVariable(
                    "DB_USER",
                    "postgres"
                );
                var dbPassword =
                    GetRequiredEnvironmentVariable("DB_PASSWORD");

                var redisHost = GetEnvironmentVariable(
                    "REDIS_HOST",
                    "redis"
                );
                var redisPort = int.Parse(
                    GetEnvironmentVariable("REDIS_PORT", "6379")
                );

                var dbConnectionString =
                    new NpgsqlConnectionStringBuilder
                    {
                        Host = dbHost,
                        Port = dbPort,
                        Database = dbName,
                        Username = dbUser,
                        Password = dbPassword
                    }.ConnectionString;

                var pgsql =
                    OpenDbConnection(dbConnectionString);

                var redisConnection =
                    OpenRedisConnection(redisHost, redisPort);

                var redis = redisConnection.GetDatabase();
                var keepAliveCommand =
                    CreateKeepAliveCommand(pgsql);

                var voteDefinition = new
                {
                    vote = "",
                    voter_id = ""
                };

                while (true)
                {
                    Thread.Sleep(100);

                    if (!redisConnection.IsConnected)
                    {
                        Console.WriteLine("Reconnecting Redis");

                        redisConnection =
                            OpenRedisConnection(
                                redisHost,
                                redisPort
                            );

                        redis = redisConnection.GetDatabase();
                    }

                    string json =
                        redis.ListLeftPopAsync("votes").Result;

                    if (json != null)
                    {
                        var vote =
                            JsonConvert.DeserializeAnonymousType(
                                json,
                                voteDefinition
                            );

                        if (vote == null)
                        {
                            Console.Error.WriteLine(
                                "Unable to deserialize vote"
                            );

                            continue;
                        }

                        Console.WriteLine(
                            $"Processing vote for '{vote.vote}' " +
                            $"by '{vote.voter_id}'"
                        );

                        if (
                            pgsql.State
                            != System.Data.ConnectionState.Open
                        )
                        {
                            Console.WriteLine(
                                "Reconnecting DB"
                            );

                            keepAliveCommand.Dispose();
                            pgsql.Dispose();

                            pgsql =
                                OpenDbConnection(
                                    dbConnectionString
                                );

                            keepAliveCommand =
                                CreateKeepAliveCommand(pgsql);
                        }

                        UpdateVote(
                            pgsql,
                            vote.voter_id,
                            vote.vote
                        );
                    }
                    else
                    {
                        try
                        {
                            keepAliveCommand.ExecuteNonQuery();
                        }
                        catch (DbException)
                        {
                            Console.WriteLine(
                                "Database keep-alive failed. " +
                                "Reconnecting DB"
                            );

                            keepAliveCommand.Dispose();
                            pgsql.Dispose();

                            pgsql =
                                OpenDbConnection(
                                    dbConnectionString
                                );

                            keepAliveCommand =
                                CreateKeepAliveCommand(pgsql);
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                Console.Error.WriteLine(exception);
                return 1;
            }
        }

        private static string GetEnvironmentVariable(
            string name,
            string defaultValue
        )
        {
            return Environment.GetEnvironmentVariable(name)
                ?? defaultValue;
        }

        private static string GetRequiredEnvironmentVariable(
            string name
        )
        {
            var value =
                Environment.GetEnvironmentVariable(name);

            if (string.IsNullOrWhiteSpace(value))
            {
                throw new InvalidOperationException(
                    $"Environment variable {name} is required"
                );
            }

            return value;
        }

        private static NpgsqlConnection OpenDbConnection(
            string connectionString
        )
        {
            NpgsqlConnection connection;

            while (true)
            {
                try
                {
                    connection =
                        new NpgsqlConnection(connectionString);

                    connection.Open();
                    break;
                }
                catch (SocketException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
                catch (DbException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
            }

            Console.Error.WriteLine("Connected to db");

            using var command = connection.CreateCommand();

            command.CommandText = @"
                CREATE TABLE IF NOT EXISTS votes (
                    id VARCHAR(255) NOT NULL UNIQUE,
                    vote VARCHAR(255) NOT NULL
                )
            ";

            command.ExecuteNonQuery();

            return connection;
        }

        private static DbCommand CreateKeepAliveCommand(
            NpgsqlConnection connection
        )
        {
            var command = connection.CreateCommand();
            command.CommandText = "SELECT 1";

            return command;
        }

        private static ConnectionMultiplexer OpenRedisConnection(
            string hostname,
            int port
        )
        {
            var ipAddress = GetIp(hostname);

            Console.WriteLine(
                $"Found Redis at {ipAddress}:{port}"
            );

            while (true)
            {
                try
                {
                    Console.Error.WriteLine(
                        "Connecting to Redis"
                    );

                    return ConnectionMultiplexer.Connect(
                        $"{ipAddress}:{port}"
                    );
                }
                catch (RedisConnectionException)
                {
                    Console.Error.WriteLine(
                        "Waiting for Redis"
                    );

                    Thread.Sleep(1000);
                }
            }
        }

        private static string GetIp(string hostname)
        {
            return Dns
                .GetHostEntryAsync(hostname)
                .Result
                .AddressList
                .First(
                    address =>
                        address.AddressFamily
                        == AddressFamily.InterNetwork
                )
                .ToString();
        }

        private static void UpdateVote(
            NpgsqlConnection connection,
            string voterId,
            string vote
        )
        {
            using var command = connection.CreateCommand();

            try
            {
                command.CommandText = @"
                    INSERT INTO votes (id, vote)
                    VALUES (@id, @vote)
                ";

                command.Parameters.AddWithValue(
                    "@id",
                    voterId
                );

                command.Parameters.AddWithValue(
                    "@vote",
                    vote
                );

                command.ExecuteNonQuery();
            }
            catch (DbException)
            {
                command.CommandText = @"
                    UPDATE votes
                    SET vote = @vote
                    WHERE id = @id
                ";

                command.ExecuteNonQuery();
            }
        }
    }
}
