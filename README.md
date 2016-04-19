# docker-portus

[![Build Status](https://travis-ci.org/h0tbird/docker-portus.svg?branch=master)](https://travis-ci.org/h0tbird/docker-portus)

This is a containerized Portus server for the Docker registry. Based on Alpine Linux.

##### 1. Certificate:

Configure one certificate to rule them all:

```
mkdir portus && cd portus

cat << EOF > ssl.conf
[ req ]
prompt             = no
distinguished_name = req_subj
x509_extensions    = x509_ext

[ req_subj ]
CN = Localhost

[ x509_ext ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:true
subjectAltName         = @alternate_names

[ alternate_names ]
DNS.1 = localhost
IP.1  = 127.0.0.1
EOF
```

Build the certificate:

```
mkdir certs && openssl req -config ssl.conf \
-new -x509 -nodes -sha256 -days 365 -newkey rsa:4096 \
-keyout certs/server-key.pem -out certs/server-crt.pem
```

Instruct docker daemon to trust the certificate:
```
sudo mkdir -p /etc/docker/certs.d/127.0.0.1:5000
sudo cp certs/server-crt.pem /etc/docker/certs.d/127.0.0.1:5000/ca.crt
sudo systemctl restart docker
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
Note that PUMA_IP is to be used if you want to have the registry and portus running on the same port but on different addresses, for example: 
  - Portus -> 10.0.0.1:443
  - Registry -> 10.0.0.2:443

##### 3. Portus:
```
cd portus && docker run -it --rm \
--net host --name portus \
--volume ${PWD}/certs:/certs \
--env DB_ADAPTER=mysql2 \
--env DB_ENCODING=utf8 \
--env DB_HOST=127.0.0.1 \
--env DB_PORT=3306 \
--env DB_USERNAME=portus \
--env DB_PASSWORD=portus \
--env DB_DATABASE=portus \
--env RACK_ENV=production \
--env RAILS_ENV=production \
--env PUMA_SSL_KEY=/certs/server-key.pem \
--env PUMA_SSL_CRT=/certs/server-crt.pem \
--env PUMA_IP=127.0.0.1 \
--env PUMA_PORT=443 \
--env PUMA_WORKERS=4 \
--env MACHINE_FQDN=127.0.0.1 \
--env SECRETS_SECRET_KEY_BASE=secret-goes-here \
--env SECRETS_ENCRYPTION_PRIVATE_KEY_PATH=/certs/server-key.pem \
--env SECRETS_PORTUS_PASSWORD=portuspw \
h0tbird/portus:latest
```

Make sure any endpoint defined in `SSL_TRUST` is up and running before starting the registry.

##### 4. Registry:
```
cd portus && docker run -it --rm \
--net host --name registry \
--volume ${PWD}/certs:/certs \
--env REGISTRY_LOG_LEVEL=info \
--env REGISTRY_HTTP_SECRET=secret-goes-here \
--env REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server-crt.pem \
--env REGISTRY_HTTP_TLS_KEY=/certs/server-key.pem \
--env REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry \
--env REGISTRY_AUTH_TOKEN_REALM=https://127.0.0.1/v2/token \
--env REGISTRY_AUTH_TOKEN_SERVICE=127.0.0.1:5000 \
--env REGISTRY_AUTH_TOKEN_ISSUER=127.0.0.1 \
--env REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/server-crt.pem \
--env SSL_TRUST=127.0.0.1:443 \
--env ENDPOINT_NAME=portus \
--env ENDPOINT_URL=https://127.0.0.1/v2/webhooks/events \
--env ENDPOINT_TIMEOUT=500 \
--env ENDPOINT_THRESHOLD=5 \
--env ENDPOINT_BACKOFF=1 \
h0tbird/registry:v2.3.0-2
```

##### 5. Docker:
```
docker login -u <user> -p <password> -e <email> 127.0.0.1:5000
docker pull busybox:latest
docker tag busybox:latest 127.0.0.1:5000/<user>/busybox:latest
docker push 127.0.0.1:5000/<user>/busybox:latest
docker rmi busybox:latest 127.0.0.1:5000/<user>/busybox:latest
docker pull 127.0.0.1:5000/<user>/busybox:latest
```
