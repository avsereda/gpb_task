FROM debian:latest

RUN apt update && apt upgrade -y 
RUN apt install -y perl cpanminus apache2-bin apache2 libapache2-mod-perl2 iputils-ping 
RUN apt install -y libcgi-pm-perl sudo mariadb-client libdbi-perl iproute2 curl libdbd-mysql-perl
RUN apt clean
RUN a2enmod perl && a2enmod cgi && a2enmod cgid
RUN cpanm -S Mojo::Template

WORKDIR /app
 
ADD lib/Local /etc/perl/Local

EXPOSE 80

ENTRYPOINT [ "/usr/sbin/apache2ctl", "-D", "FOREGROUND" ] 
