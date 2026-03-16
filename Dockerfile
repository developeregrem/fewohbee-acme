# docker-compose build
FROM python:3.14-alpine

RUN apk add --no-cache \
        tzdata \
        openssl \
        bash

RUN apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        musl-dev \
        openssl-dev \
        cargo \ 
        && pip install --no-cache-dir certbot certbot-dns-desec \
        && apk del .build-deps    

RUN mkdir /certs && mkdir /dummyssl

COPY ./run.sh /
COPY ./acme-entrypoint.sh /
COPY ./updatecert /etc/periodic/daily/
COPY ./ssl-example/ /dummyssl/

RUN chmod +x /run.sh /acme-entrypoint.sh && chmod 0744 /etc/periodic/daily/updatecert

CMD ["/acme-entrypoint.sh"]
