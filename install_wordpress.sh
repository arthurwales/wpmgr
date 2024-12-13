#!/bin/bash

# Exit on error
set -e

echo "Installing WordPress..."

# Load database credentials
source /root/.wp_db_credentials

# Download WordPress
cd /var/www/wordpress
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz --strip-components=1
rm latest.tar.gz

# Configure WordPress
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php

# Set up WordPress salts
wget -qO- https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php

# Set correct permissions
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress/ -type d -exec chmod 755 {} \;
find /var/www/wordpress/ -type f -exec chmod 644 {} \;

echo "WordPress installation completed"