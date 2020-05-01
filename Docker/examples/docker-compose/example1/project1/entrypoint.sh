#!/bin/sh

#- exit script if any command fails (non-zero value)
set -e 

echo "---------------------- merhaba bu entrypoint den --------------------------"


exec "$@"