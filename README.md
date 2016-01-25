# docker-portus

[![Build Status](https://travis-ci.org/h0tbird/docker-portus.svg?branch=master)](https://travis-ci.org/h0tbird/docker-portus)

This is a containerized Portus server.

##### 1. Certificate:
```
mkdir certs && openssl req \
-newkey rsa:4096 -nodes -sha256 -x509 -days 365 \
-subj '/CN=127.0.0.1/O=Localhost LTD./C=US' \
-keyout certs/server.key -out certs/server.crt
```

##### 2. MariaDB:
```
docker run -it --rm \
--net host --name mariadb \
--env MYSQL_ROOT_PASSWORD=portus \
--env MYSQL_USER=portus \
--env MYSQL_PASSWORD=portus \
--env MYSQL_DATABASE=portus \
mariadb:10
```

##### 3. Registry:
```
docker run -it --rm \
--net host --name registry \
--volume ${PWD}/certs:/certs \
--env REGISTRY_HTTP_SECRET=secret-goes-here \
--env REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.crt \
--env REGISTRY_HTTP_TLS_KEY=/certs/server.key \
--env REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry \
--env REGISTRY_AUTH_TOKEN_REALM=http://127.0.0.1/v2/token \
--env REGISTRY_AUTH_TOKEN_SERVICE=127.0.0.1:5000 \
--env REGISTRY_AUTH_TOKEN_ISSUER=127.0.0.1 \
--env REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/server.crt \
--env ENDPOINT_NAME=portus \
--env ENDPOINT_URL=http://127.0.0.1/v2/webhooks/events \
--env ENDPOINT_TIMEOUT=500 \
--env ENDPOINT_THRESHOLD=5 \
--env ENDPOINT_BACKOFF=1 \
h0tbird/registry:v2.2.1-3
```

##### 4. Portus:
```
docker run -it --rm \
--net host --name portus \
--volume ${PWD}/certs:/certs \
--env DB_ADAPTER=mysql2 \
--env DB_ENCODING=utf8 \
--env DB_HOST=127.0.0.1 \
--env DB_PORT=3306 \
--env DB_USERNAME=portus \
--env DB_PASSWORD=portus \
--env DB_DATABASE=portus \
--env SECRETS_SECRET_KEY_BASE=secret-goes-here \
--env SECRETS_ENCRYPTION_PRIVATE_KEY_PATH=/certs/server.key \
--env SECRETS_MACHINE_FQDN=127.0.0.1 \
--env SECRETS_PORTUS_PASSWORD=portus \
h0tbird/portus:latest
```

##### 5. Docker:
```
docker login -u <user> -p <password> -e <email> 127.0.0.1:5000
```
