#!/bin/sh

#- exit script if any command fails (non-zero value)
set -e 

echo "---------------------- merhaba bu entrypoint den --------------------------"

echo "Girilen HOST_ENV" $HOST_ENV
echo "---------------------------------------------------"
echo "Girilen PORT_ENV" $PORT_ENV

# bu komut aslında boşlukta veri okuyup durur
# böylece bu container kapanmadan evam eder. 
tail -f /dev/null

exec "$@"