FROM alpine

ARG version=4
   
RUN set -xe \
    && apk --no-cache add alpine-conf openssl ca-certificates curl build-base  perl openssl-dev

EXPOSE 3128

COPY docker-entrypoint.sh configs configs_switch configure_squid.sh  /
ADD config /etc/squid/

RUN chmod +x /docker-entrypoint.sh /configure_squid.sh
RUN ./configure_squid.sh $version

VOLUME /etc/squid/

ENTRYPOINT ["/docker-entrypoint.sh"]
