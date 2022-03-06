#!/bin/ash

# from sameersbn/docker-squid
set -xe

cat /etc/squid/squid.conf.basic



if [ -z ${1} ]; then

  # echo "Starting squid..."
  exec tail -f /var/log/squid/access.log

else
  exec "$@"
fi

