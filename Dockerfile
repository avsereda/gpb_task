# syntax=docker/dockerfile:1

FROM debian:latest

RUN apt update && apt upgrade -y 
RUN apt install -y perl cpanminus apache2-bin apache2 libapache2-mod-perl2 iputils-ping 
RUN apt install -y libcgi-pm-perl sudo mariadb-client libdbi-perl iproute2 curl libdbd-mysql-perl
RUN apt clean
RUN a2enmod perl && a2enmod cgi && a2enmod cgid
RUN cpanm -S Mojo::Template

WORKDIR /app
 
ADD cgi-bin /usr/lib/cgi-bin
ADD lib/Local /etc/perl/Local
ADD setup.pl .
ADD mysql_schema.sql .
ADD mail_log_parse.pl .
ADD assets/out.zip assets/out.zip

EXPOSE 80

ENTRYPOINT [ "/app/setup.pl" ] 
