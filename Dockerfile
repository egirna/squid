FROM alpine

ENV SOURCE_URL=
ENV ENABLE_ICAP=--enable-icap-client

# RUN set -xe \
#     && apk --no-cache add alpine-conf openssl ca-certificates curl \
#     && apk --no-cache add squid \
#     && mkdir -p /etc/squid/cert \
#     && mkdir -p /var/cache/squid \
#     && touch /var/log/squid/access.log
   
RUN set -xe \
    && apk --no-cache add alpine-conf openssl ca-certificates curl build-base  perl openssl-dev \
    && wget -O - http://www.squid-cache.org/Versions/v4/squid-4.17.tar.gz | tar zxfv - \
    && cd squid-4.17 \
    && ./configure --prefix=/usr --datadir=/usr/share/squid \
    --sysconfdir=/etc/squid --libexecdir=/usr/lib/squid --localstatedir=/var --with-logdir=/var/log/squid --disable-strict-error-checking \ 
    ${ENABLE_ICAP} --enable-ssl --with-openssl --enable-ssl-crtd --enable-auth --enable-basic-auth-helpers="NCSA" \
    && make \
    && make install \
    && mkdir -p /etc/squid/cert \
    && mkdir -p /var/cache/squid \
    && touch /var/log/squid/access.log \
    && touch /var/log/squid/cache.log
    # && echo "env.list"



EXPOSE 3128

COPY docker-entrypoint.sh /
COPY config/squid.conf /etc/squid/squid.conf

RUN chmod +x /docker-entrypoint.sh


VOLUME /etc/squid/


ENTRYPOINT ["/docker-entrypoint.sh"]