FROM php:7.1-apache
COPY ./receiver.php /var/www/html/
COPY uploads.ini $PHP_INI_DIR/conf.d/
#WORKDIR /var/www/html
#USER var-www
#CMD [ "php", "./receiver.php" ]
