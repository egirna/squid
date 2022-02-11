#!/bin/ash

. env.list
# from sameersbn/docker-squid
set -xe

configure_squid4(env.list) {
    wget -O - http://www.squid-cache.org/Versions/v4/squid-4.17.tar.gz | tar zxfv - \
    && cd squid-4.17 \
    && ./configure --prefix=/usr --datadir=/usr/share/squid \
    --sysconfdir=/etc/squid --libexecdir=/usr/lib/squid --localstatedir=/var --with-logdir=/var/log/squid --disable-strict-error-checking --with-default-user=squid \ 
    ${ENABLE_ICAP} --enable-ssl --with-openssl --enable-ssl-crtd --enable-auth --enable-basic-auth-helpers="NCSA" \
    && make \
    && make install \
}

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

chmod -R 1777 /var/log/squid
chown -R squid:squid /var/log/squid/


if [[ -z ${1} ]]; then

  # echo "Starting squid..."
  exec tail -f /var/log/squid/access.log

else
  exec "$@"
fi

