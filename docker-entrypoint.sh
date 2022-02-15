#!/bin/ash


switch_file=configs_switch
config_file=configs
enabled_services=""
enabled_arguments=""

# from sameersbn/docker-squid
set -xe

setup_squid4() {
    cd squid-4.17 \
    && $(configure_squid) \
    && make \
    && make install \
    && echo "installation complete"
    
}

configure_squid(){
while read -r f1 f2 f3
do
        if [ "$f3" -eq 0 ]
        then
            continue
        
        elif [ "$f3" -eq 1 ]
        then 
            enabled_services="${enabled_services} ${f1}"
        else
            printf 'incorrect value for %s \n' "$f1"
            exit 1
        fi
done <"$switch_file" 

for i in "${enabled_services}";
do 
	value="$(awk -F' = ' -v x="$i" '$1==x {print $2}' configs)"
        enabled_arguments="${enabled_arguments} ${value}"
done
configure_command="./configure --prefix=/usr --datadir=/usr/share/squid   --sysconfdir=/etc/squid --libexecdir=/usr/lib/squid --localstatedir=/var --with-logdir=/var/log/squid --disable-strict-error-checking $enabled_arguments  --enable-auth --enable-basic-auth-helpers='NCSA'"
echo ${configure_command}
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




#setup_squid4
create_cert
clear_certs_db

cat /etc/squid/squid.conf

chmod -R 1777 /var/log/squid
chown -R squid:squid /var/log/squid/


if [ -z ${1} ]; then

  # echo "Starting squid..."
  exec tail -f /var/log/squid/access.log

else
  exec "$@"
fi

