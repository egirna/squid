#!/bin/ash

set -xe

switch_file=configs_switch
config_file=configs
enabled_services=""
enabled_arguments=""

setup_squid4() {
    wget -O - http://www.squid-cache.org/Versions/v4/squid-4.17.tar.gz | tar zxfv - \
    && cd squid-4.17 \
    cd squid-4.17 \
    && $(configure_squid) \
    && make \
    && make install \
    && echo "installation complete" \
    && mkdir -p /etc/squid/cert \
    && mkdir -p /var/cache/squid \
    && touch /var/log/squid/access.log \
    && touch /var/log/squid/cache.log
    
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

configure_command="./configure --prefix=/usr --datadir=/usr/share/squid  --sysconfdir=/etc/squid --libexecdir=/usr/lib/squid --localstatedir=/var --with-logdir=/var/log/squid --disable-strict-error-checking --enable-ssl --with-openssl --enable-ssl-crtd --enable-auth --enable-basic-auth-helpers='NCSA' ${enabled_arguments} "
echo ${configure_command}
}
setup_squid4
