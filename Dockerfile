ARG ALP_IMG=alpine:3.12
FROM ${ALP_IMG}

RUN set -xe \
    && apk --no-cache add alpine-conf openssl ca-certificates curl \
    && apk --no-cache add squid \
    && mkdir -p /etc/squid/cert \
    && mkdir -p /var/cache/squid \
    && touch /var/log/squid/access.log
   

EXPOSE 3128

COPY docker-entrypoint.sh /
COPY config/squid.conf /etc/squid/squid.conf

RUN chmod +x /docker-entrypoint.sh


VOLUME /etc/squid/


ENTRYPOINT ["/docker-entrypoint.sh"]