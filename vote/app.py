from flask import Flask, render_template, request, make_response, g, jsonify
from redis import Redis

import json
import logging
import os
import random
import socket


option_a = os.getenv("OPTION_A", "Cats")
option_b = os.getenv("OPTION_B", "Dogs")

redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", "6379"))
redis_db = int(os.getenv("REDIS_DB", "0"))
redis_socket_timeout = float(
    os.getenv("REDIS_SOCKET_TIMEOUT", "5")
)

hostname = socket.gethostname()

app = Flask(__name__)

gunicorn_error_logger = logging.getLogger("gunicorn.error")
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.INFO)


def get_redis():
    if not hasattr(g, "redis"):
        g.redis = Redis(
            host=redis_host,
            port=redis_port,
            db=redis_db,
            socket_timeout=redis_socket_timeout,
        )

    return g.redis


@app.route("/health", methods=["GET"])
def health():
    return jsonify(
        status="healthy",
        service="vote",
    ), 200


@app.route("/ready", methods=["GET"])
def ready():
    try:
        get_redis().ping()
    except Exception as error:
        app.logger.warning(
            "Redis readiness check failed: %s",
            error,
        )

        return jsonify(
            status="not_ready",
            service="vote",
            dependency="redis",
        ), 503

    return jsonify(
        status="ready",
        service="vote",
    ), 200


@app.route("/", methods=["POST", "GET"])
def hello():
    voter_id = request.cookies.get("voter_id")

    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = None

    if request.method == "POST":
        redis = get_redis()
        vote = request.form["vote"]

        app.logger.info("Received vote for %s", vote)

        data = json.dumps(
            {
                "voter_id": voter_id,
                "vote": vote,
            }
        )

        redis.rpush("votes", data)

    response = make_response(
        render_template(
            "index.html",
            option_a=option_a,
            option_b=option_b,
            hostname=hostname,
            vote=vote,
        )
    )

    response.set_cookie("voter_id", voter_id)

    return response


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=80,
        debug=True,
        threaded=True,
    )
