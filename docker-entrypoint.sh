#!/bin/ash

# from sameersbn/docker-squid
set -xe

cat /etc/squid/squid.conf.basic



if [ -z ${1} ]; then

  # echo "Starting squid..."
  echo "===================================================="
  echo "===================================================="
  echo $(tail -f /var/log/squid/access.log)
  exec tail -f /var/log/squid/access.log
  
  echo "===================================================="
  echo "===================================================="

else
  exec "$@"
fi

