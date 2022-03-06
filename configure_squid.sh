#!/bin/ash

set -xe

SSL_ENABLED=false

switch_file=configs_switch
enabled_services=""
enabled_arguments=""

download_squid(){
if [ "$1" -eq 4 ]
then
     wget -O - http://www.squid-cache.org/Versions/v4/squid-4.17.tar.gz | tar zxfv - \
    && cd squid-4.17
elif [ "$1" -eq 5 ]
then
        wget -O  - http://www.squid-cache.org/Versions/v5/squid-5.4.1.tar.gz |  tar zxfv - \
        && cd squid-5.4.1
else
        printf 'incorect version value %s \n' "$1"
        exit 1
fi
 }

#configure squid with customized flags
setup_squid(){
    $1 \
    && make \
    && make install \
    && echo "installation complete" \
    && mkdir -p /etc/squid/cert \
    && mkdir -p /var/cache/squid \
    && touch /var/log/squid/access.log \
    && touch /var/log/squid/cache.log  \
    && chmod -R 1777 /var/log/squid \
    && chown -R squid:squid /var/log/squid/
    
}

find_enabled_services(){
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
echo "${enabled_services}"

}


configure_squid(){
for i in ${1};
do 
        value="$(awk -F' = ' -v x="$i" '$1==x {print $2}' configs)"
        enabled_arguments="${enabled_arguments} ${value}"
done

configure_command="./configure --prefix=/usr --datadir=/usr/share/squid  --sysconfdir=/etc/squid --libexecdir=/usr/lib/squid --localstatedir=/var --with-logdir=/var/log/squid --disable-strict-error-checking ${enabled_arguments}"
echo ${configure_command}
}

check_requirements(){

for i in ${1};
do
	case "${i}" in
	"ENABLE_ECAP")
		wget  http://www.e-cap.org/archive/libecap-1.0.1.tar.gz  \
		&& tar -zxvf libecap-1.0.1.tar.gz && cd libecap-1.0.1  \
		&& export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/libecap-1.0.1 &&  ./configure  \
        	&& make && make install &&  cd /
	;;

	"ENABLE_ESI")
		apk add libxml2 libxml2-dev
	;;
	esac

done
}

is_ssl_enabled(){
        value="$(awk -F' = ' '$1=="ENABLE_SSL" {print $2}' configs_switch)"
        if [ $value -eq 0 ]
        then
                SSL_ENABLED=false
        else
                SSL_ENABLED=true
        fi
}

create_cert() {
    if [ ! -f "/etc/squid/cert/ca_key.pem" ] || [ ! -f "/etc/squid/cert/ca_cert.pem" ]; then
        echo "Creating certificate..."
        openssl req -new -newkey rsa:2048 -x509 -days 365 -nodes \
            -keyout "/etc/squid/cert/ca_key.pem" -out "/etc/squid/cert/ca_cert.pem" \
            -subj "/C=EG/ST=Global/L=Global/O=Egirna Technologies/OU=Egirna Technologies/CN=squid.local/" -utf8 -nameopt multiline,utf8
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

#specify which configuration file to use
run_basic_config_file(){
	squid -f /etc/squid/squid.conf.basic
}

run_ssl_config_file(){
        squid -f /etc/squid/squid.conf.ssl
}


main(){
services="$(find_enabled_services)"
check_requirements "${services}"
configure_command=$(configure_squid "${services}")
is_ssl_enabled
#download squid and passing version number to the function
download_squid "$1"

#configure squid
setup_squid "$configure_command"

#check if ssl functions(create_cert and clear_certs_db) should be used, and run the config file
if [ $SSL_ENABLED == false ]
then
	run_basic_config_file
elif [ $SSL_ENABLED = true ]
then
	create_cert
	clear_certs_db
        run_ssl_config_file
fi

}

main $1

