#!/bin/ash

# from sameersbn/docker-squid
set -xe

cat /etc/squid/squid.conf.basic

chmod -R 1777 /var/log/squid
chown -R squid:squid /var/log/squid/


if [ -z ${1} ]; then

  # echo "Starting squid..."
  exec tail -f /var/log/squid/access.log

else
  exec "$@"
fi

