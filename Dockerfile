FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql zip
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

RUN a2enmod rewrite

COPY . /var/www/html
WORKDIR /var/www/html


RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-plugins --no-scripts --prefer-dist --no-progress --no-suggest --no-interaction

RUN sed -i 's|/var/www/html|/var/www/html/web|g' /etc/apache2/sites-available/000-default.conf
RUN echo "DirectoryIndex index.php" >> /etc/apache2/mods-enabled/dir.conf

RUN chown -R www-data:www-data /var/www/html/runtime /var/www/html/web/assets

EXPOSE 80

CMD ["apache2-foreground"]