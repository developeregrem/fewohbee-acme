#!/bin/sh

privkey=/certs/privkey.pem
certfile=/certs/fullchain.pem

restart_containers(){
    containers=`curl -gGs --unix-socket /var/run/docker.sock http://${DOCKER_API_VERSION}/containers/json?all=true --data-urlencode 'filters={"label":{"com.docker.compose.service=web":true}}' | jq -r .[].Id`

    for container in $containers; do
        curl --unix-socket /var/run/docker.sock -X POST http:/${DOCKER_API_VERSION}/containers/$container/restart
    done
}

selfsignedcert(){
    cn="/CN=${HOST_NAME}"    
    openssl req -subj `echo $cn` -x509 -nodes -days 365 -newkey rsa:2048 -keyout $privkey -out $certfile
    restart_containers
}

letsencryptcert(){
    echo "Letsencryptcert"
    # create for each subdomain a -d entry for certbot
    domains=""
    for domain in ${LETSENCRYPT_DOMAINS}
    do
        domains="${domains} -d ${domain}"
    done

    if [ "${domains}" = "" ] 
    then
        echo "No domain specified in LETSENCRYPT_DOMAINS!"
        return 1
    fi

    if [ "${DYNDNS_PROVIDER}" = "desec.io" ]
    then
        dedynauth
        certbot certonly \
            --authenticator dns-desec \
            --dns-desec-credentials /etc/letsencrypt/secrets/${DEDYN_NAME}.ini \
            `echo $domains` \
            --agree-tos \
            --no-eff-email \
            --email "${EMAIL}"
    else
        certbot certonly \
    	    --agree-tos \
    	    --webroot \
    	    -w /var/www \
    	    `echo $domains` \
    	    --renew-by-default \
            --no-eff-email \
    	    --email "${EMAIL}"
    fi

    if [ -f "/etc/letsencrypt/live/${HOST_NAME}/fullchain.pem" ]
        then
        cp /etc/letsencrypt/live/${HOST_NAME}/fullchain.pem /certs
        cp /etc/letsencrypt/live/${HOST_NAME}/privkey.pem /certs
        restart_containers
    fi
}

dedynauth() {
    if [ "${DYNDNS_PROVIDER}" = "desec.io" ] && [ ! -d "/etc/letsencrypt/secrets/" ]
    then
        mkdir -p /etc/letsencrypt/secrets/
        chmod 700 /etc/letsencrypt/secrets/
        echo "dns_desec_token = ${DEDYN_TOKEN}" | tee /etc/letsencrypt/secrets/${DEDYN_NAME}.ini
        chmod 600 /etc/letsencrypt/secrets/${DEDYN_NAME}.ini
    fi
}

method=""

if [ "${LETSENCRYPT}" = "true" ]
then
    method=letsencryptcert
elif [ "${SELF_SIGNED}" = "true" ]
then
    method=selfsignedcert
fi


# first run, when no certificate exists create one
if [ ! -f "$certfile" ]
then
    cp /dummyssl/* /certs
    
    restart_containers
	# generate dh params
#	openssl dhparam -out /certs/dhparams.pem 4096
    $method
fi

# check validity of certificate, < 30 days? => renew
if ! openssl x509 -checkend 2592000 -noout -in $certfile
then
    echo "renew"
    $method
fi

return 0
