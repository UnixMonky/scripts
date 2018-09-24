#!/bin/bash

REGION="us-east-1"

while getopts ":r:" opt; do
  case $opt in
    r)
      REGION=${OPTARG} ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

case $REGION in
  "us-east-1" ) IP=10.162.2.100; PORT=6901 ;;
  "eu-central-1" ) IP=10.162.66.111; PORT=6902 ;;
esac

echo -n "Starting SSH-Socks Proxy to $REGION..."
ssh -D ${PORT} -f -q -N ${IP}
PROXY_PID=$!
echo "done."

echo -n "Press ^C to cancel proxy"
sleep infinity
kill $PROXY_PID
echo "Proxy closed"
