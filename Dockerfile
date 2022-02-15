FROM alpine

ENV SOURCE_URL=
   
RUN set -xe \
    && apk --no-cache add alpine-conf openssl ca-certificates curl build-base  perl openssl-dev

EXPOSE 3128

COPY docker-entrypoint.sh /
COPY config/squid.conf /etc/squid/squid.conf
COPY configs /
COPY configs_switch /
COPY configure_squid.sh /

RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /configure_squid.sh
RUN ./configure_squid.sh

VOLUME /etc/squid/


ENTRYPOINT ["/docker-entrypoint.sh"]
