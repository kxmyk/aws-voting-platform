#!/bin/sh

while ! timeout 1 bash -c "echo > /dev/tcp/vote/80"; do
  sleep 1
done

curl -sS -X POST --data "vote=b" http://vote > /dev/null
sleep 10

if phantomjs render.js http://result | grep -q '1 vote'; then
  printf '\033[42m------------\033[0m\n'
  printf '\033[92mTests passed\033[0m\n'
  printf '\033[42m------------\033[0m\n'
  exit 0
else
  printf '\033[41m------------\033[0m\n'
  printf '\033[91mTests failed\033[0m\n'
  printf '\033[41m------------\033[0m\n'
  exit 1
fi
