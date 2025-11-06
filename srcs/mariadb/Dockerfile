FROM debian:12-slim

RUN apt-get update && apt-get install -y mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

COPY conf/address.conf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306
CMD ["/usr/local/bin/entrypoint.sh"]