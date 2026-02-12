FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql mbstring gd zip opcache \
    && a2enmod rewrite headers expires \
    && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && rm -rf /var/lib/apt/lists/*

RUN cat > /etc/apache2/sites-available/000-default.conf <<'APACHE'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <LocationMatch "^/\.">
        Require all denied
    </LocationMatch>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
APACHE

WORKDIR /var/www/html

COPY . .

RUN mkdir -p /var/www/html/runtime/view/compile \
    /var/www/html/runtime/view/cache \
    /var/www/html/runtime/tmp \
    /var/www/html/runtime/waf \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/runtime

EXPOSE 80
