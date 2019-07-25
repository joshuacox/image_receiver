FROM php:7.1-apache
COPY ./receiver.php /var/www/html/
#WORKDIR /var/www/html
#USER var-www
#CMD [ "php", "./receiver.php" ]
