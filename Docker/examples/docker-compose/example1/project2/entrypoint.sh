#!/bin/sh

#- exit script if any command fails (non-zero value)
set -e 

cat /home/myvolume/copyfile.txt

exec "$@"