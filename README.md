

# fewohbee-acme

This Docker image provides an Automatic Certificate Management Environment (ACME) which is used together with fewohbee-dockerized to either use a self-signed certificate or one from letsencrypt. Automtic renew of the certificates is also enabled.
It also supports the free DNS provider [desec.io](https://desec.io).

## supported tags
 - `:latest` - always pull the latest image

## Supported architectures  
`amd64`,  `arm64v8`
		
## Volume structure

 - `/var/www` - web accessible resources in order to allow letsencrypt verification
 - `/var/run/docker.sock` - used to restart the web container after a certificate renewal
 - `/certs` - the location where the certificates will be stored

## Environment variables

- `TZ` - time zone e.g. "Europe/Berlin"
- `HOST_NAME` - e.g. localhost, used for self-signed certificates
- `LETSENCRYPT_DOMAINS` - enter here all (sub-)domains which should be included in the certificate, sepearated with a whitespace e.g.: domain.tld sub1.domain.tld
- `EMAIL` - your eMail address to get informed when your letsencrypt certificate is about to expire (usually no action is required, mails will be recieved only in case of something went wrong during renewal)
- `SELF_SIGNED` - bool, if using self-signed certificate
- `LETSENCRYPT` - bool, if using letsencrypt
- `DOCKER_API_VERSION` - the version of the docker api
- `DYNDNS_PROVIDER` - if used specify your dyndns provider, currently "desec.io" is supported, leave empty if not used
- `DEDYN_TOKEN` - place your dedyn.io access token here
- `DEDYN_NAME` - set your dedyn.io domain name here
 
## Example usage

This image is part of the [fewohbee-dockerized](https://github.com/developeregrem/fewohbee-dockerized) docker-compose setup. A docker-compose file can be found here:

- https://github.com/developeregrem/fewohbee-dockerized
