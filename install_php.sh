#!/bin/bash

# Exit on error
set -e

PHP_VERSION=${1:-"8.1"}

echo "Installing PHP ${PHP_VERSION}..."

# Add PHP repository
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update

# Install PHP and extensions
apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-soap

# Configure PHP
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 64M/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 64M/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php/${PHP_VERSION}/fpm/php.ini

# Restart PHP-FPM
systemctl restart php${PHP_VERSION}-fpm

echo "PHP ${PHP_VERSION} installation completed"