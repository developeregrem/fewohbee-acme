# docker-compose build
FROM python:3.11-alpine

RUN apk add --no-cache \
        curl \
        tzdata \
        jq \
        openssl \
        dialog \
        bash       

RUN apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        musl-dev \
        openssl-dev \
        cargo \ 
        && pip install --no-cache-dir certbot \
        && apk del .build-deps    

RUN mkdir /certs && mkdir /dummyssl

COPY ./run.sh /
COPY ./updatecert /etc/periodic/daily/
COPY ./ssl-example/ /dummyssl/

RUN chmod +x /run.sh && chmod 0744 /etc/periodic/daily/updatecert

CMD [ "crond", "-f" ]
