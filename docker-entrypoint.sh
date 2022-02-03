#!/bin/ash

# from sameersbn/docker-squid
set -xe


create_cert() {
    if [ ! -f "/etc/squid/cert/ca_key.pem" ] || [ ! -f "/etc/squid/cert/ca_cert.pem" ]; then
        echo "Creating certificate..."
        openssl req -new -newkey rsa:4096 -x509 -days 365 -nodes \
            -keyout "/etc/squid/cert/ca_key.pem" -out "/etc/squid/cert/ca_cert.pem" \
            -subj "/C=/ST=Global/L=Global/O=Squid/OU=Squid/CN=squid.local/" -utf8 -nameopt multiline,utf8
        cat "/etc/squid/cert/ca_cert.pem" "/etc/squid/cert/ca_key.pem" > "/etc/squid/cert/ca_chain.pem"
    else
        echo "Certificate found..."
    fi

    if [ ! -f "/etc/squid/cert/ca_cert.der" ]; then
        # ls -a /etc/squid/cert
        openssl x509 -in "/etc/squid/cert/ca_cert.pem" -outform DER -out "/etc/squid/cert/ca_cert.der"
    fi
}

clear_certs_db() {
   if [ ! -d "/var/cache/squid/ssl_db" ]; then
        echo "Clearing generated certificate db..."
        /usr/lib/squid/security_file_certgen -c -s "/var/cache/squid/ssl_db" -M 4MB
        chown -R squid /var/cache/squid/ssl_db

   fi
}


create_cert
clear_certs_db

cat /etc/squid/squid.conf

chown -R squid:squid /var/log/squid/
# chmod 644 /var/log/squid/

if [[ -z ${1} ]]; then
#   if [[ ! -d /var/cache/squid ]]; then
#     echo "Initializing cache..."
#     $(which squid) -N -f /etc/squid/squid.conf -z
#   fi
  
  echo "Starting squid..."
  $(which squid) -z
  exec tail -f /var/log/squid/access.log

    
#   exec squid -v
#   exec cat /etc/squid/squid.conf
#   exec $(which squid) -f /etc/squid/squid.conf 
#   exec $(which squid) -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}

else
  exec "$@"
fi

