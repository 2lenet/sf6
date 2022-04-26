FROM registry.2le.net/2le/2le:base-sf5-php8 as config
RUN apt-get update && apt-get install -y wget
RUN mkdir -p /var/www/.cache && chown www-data /var/www/.cache && chgrp www-data /var/www/.cache
RUN mkdir -p /var/www/.config && chown www-data /var/www/.config && chgrp www-data /var/www/.config
RUN mkdir -p /var/lib/php/sessions && chmod 777 /var/lib/php/sessions
COPY ./docker/apache/default.conf /etc/apache2/sites-available/000-default.conf
COPY . /var/www/html/
WORKDIR /var/www/html
ENV APP_NAME="Gédéon IA"
ARG app_version=dev
ENV APP_VERSION=$app_version
RUN COMPOSER_MEMORY_LIMIT=-1
RUN composer install
RUN bin/console assets:install
RUN a2enmod http2
RUN npm install
RUN npm run build
VOLUME ["/var/www/html/var/cache"]
EXPOSE 80
CMD ["sh", "-c", "make prepare && apache2-foreground"]
