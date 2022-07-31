# docker-compose build
FROM python:3.9-alpine

RUN apk add --no-cache \
        curl \
        tzdata \
        jq \
        gcc \
        musl-dev \
        libffi-dev \
        openssl \
        openssl-dev \
        dialog \
        bash \
        cargo

RUN pip install certbot        

RUN mkdir /certs
RUN mkdir /dummyssl

COPY ./run.sh /
COPY ./updatecert /etc/periodic/daily/
COPY ./ssl-example/ /dummyssl/

RUN chmod +x /run.sh && chmod 0744 /etc/periodic/daily/updatecert

CMD [ "crond", "-f" ]
