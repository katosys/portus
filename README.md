# docker-portus

[![Build Status](https://travis-ci.org/h0tbird/docker-portus.svg?branch=master)](https://travis-ci.org/h0tbird/docker-portus)

This is a containerized Portus server.


##### MariaDB:
```
docker run -it --rm \
--net host \
--env MYSQL_ROOT_PASSWORD=portus \
--env MYSQL_USER=portus \
--env MYSQL_PASSWORD=portus \
--env MYSQL_DATABASE=portus \
mariadb:10
```

##### Portus:
```
docker run -it --rm \
--net host \
--env DB_ADAPTER=mysql2 \
--env DB_ENCODING=utf8 \
--env DB_HOST=127.0.0.1 \
--env DB_PORT=3306 \
--env DB_USERNAME=portus \
--env DB_PASSWORD=portus \
--env DB_DATABASE=portus \
h0tbird/portus:v2.0.0-1
```
