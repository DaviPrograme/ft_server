FROM debian:buster

RUN apt update && apt install -y nginx mariadb-server php-fpm php-mysql openssl unzip

COPY ./srcs/wordpress.zip /var/www/html
COPY ./srcs/phpmyadmin.zip /var/www/html
COPY ./srcs/wordpress.sql /var/www/html
COPY ./srcs/start /usr/local/bin
COPY ./srcs/autoindex /usr/local/bin
COPY ./srcs/autoindex.conf /etc/nginx
COPY ./srcs/nginx.conf /etc/nginx
RUN chmod u+x /usr/local/bin/autoindex
RUN chmod u+x /usr/local/bin/start
RUN chmod 777 /var/www/html/wordpress.sql

RUN cd /var/www/html && unzip wordpress.zip && unzip phpmyadmin.zip

RUN service mysql start && mysql -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '12345'; CREATE DATABASE wordpress; GRANT ALL ON wordpress.* TO 'wordpress'@'localhost';"
RUN service mysql start && mysql wordpress < /var/www/html/wordpress.sql
RUN cd /var/www/html && rm wordpress.zip phpmyadmin.zip wordpress.sql

RUN mkdir /etc/ssl/nginx
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/private.key -out /etc/ssl/nginx/public.crt -subj "/C=42/ST=SP/L=SP/O=Global Security/OU=FT Server/CN=localhost"

ENTRYPOINT start
