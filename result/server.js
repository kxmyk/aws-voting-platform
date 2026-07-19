const express = require('express');
const async = require('async');
const { Pool } = require('pg');
const cookieParser = require('cookie-parser');
const path = require('path');

const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server);

const port = process.env.PORT || 4000;
const dbPassword = process.env.DB_PASSWORD;

if (!dbPassword) {
  throw new Error('DB_PASSWORD environment variable is required');
}

const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: Number.parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME || 'postgres',
  user: process.env.DB_USER || 'postgres',
  password: dbPassword
});

app.get('/health', function (request, response) {
  response.status(200).json({
    status: 'healthy',
    service: 'result'
  });
});

app.get('/ready', async function (request, response) {
  try {
    await pool.query('SELECT 1');

    response.status(200).json({
      status: 'ready',
      service: 'result'
    });
  } catch (error) {
    response.status(503).json({
      status: 'not_ready',
      service: 'result',
      dependency: 'postgres'
    });
  }
});

io.on('connection', function (socket) {
  socket.emit('message', {
    text: 'Welcome!'
  });

  socket.on('subscribe', function (data) {
    socket.join(data.channel);
  });
});

async.retry(
  {
    times: 1000,
    interval: 1000
  },
  function (callback) {
    pool.connect(function (error, client) {
      if (error) {
        console.error('Waiting for db');
      }

      callback(error, client);
    });
  },
  function (error, client) {
    if (error) {
      return console.error('Giving up');
    }

    console.log('Connected to db');
    getVotes(client);
  }
);

function getVotes(client) {
  client.query(
    'SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote',
    [],
    function (error, result) {
      if (error) {
        console.error('Error performing query: ' + error);
      } else {
        const votes = collectVotesFromResult(result);
        io.sockets.emit('scores', JSON.stringify(votes));
      }

      setTimeout(function () {
        getVotes(client);
      }, 1000);
    }
  );
}

function collectVotesFromResult(result) {
  const votes = {
    a: 0,
    b: 0
  };

  result.rows.forEach(function (row) {
    votes[row.vote] = Number.parseInt(row.count, 10);
  });

  return votes;
}

app.use(cookieParser());
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'views')));

app.get('/', function (request, response) {
  response.sendFile(
    path.resolve(__dirname, 'views/index.html')
  );
});

server.listen(port, function () {
  console.log(
    'App running on port ' + server.address().port
  );
});
