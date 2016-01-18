# docker-portus
Dockerized Portus server


MariaDB:
```
docker run -it --rm \
--net host \
--env MYSQL_ROOT_PASSWORD=portus \
--env MYSQL_USER=portus \
--env MYSQL_PASSWORD=portus \
--env MYSQL_DATABASE=portus \
mariadb:latest
```

Portus:
```
docker run -it --rm \
--net host \
--env DB_ADAPTER=mysql2 \
--env DB_ENCODING=utf8 \
--env DB_HOST=127.0.0.1 \
--env DB_PORT=3306 \
--env DB_USERNAME=root \
--env DB_PASSWORD=portus \
--env DB_DATABASE=portus \
h0tbird/portus:latest
```
