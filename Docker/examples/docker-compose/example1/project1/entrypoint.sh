#!/bin/sh

#- exit script if any command fails (non-zero value)
set -e 

echo "---------------------- merhaba bu entrypoint den --------------------------"

echo "Girilen HOST_ENV" $HOST_ENV
echo "---------------------------------------------------"
echo "Girilen PORT_ENV" $PORT_ENV

sleep 120s

exec "$@"