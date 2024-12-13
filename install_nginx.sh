#!/bin/bash

# Exit on error
set -e

echo "Installing Nginx..."

# Update package list
apt-get update

# Install Nginx
apt-get install -y nginx

# Create Nginx configuration for WordPress
cat > /etc/nginx/sites-available/wordpress << 'EOL'
server {
    listen 80;
    root /var/www/wordpress;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Enable the site
ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Create web root
mkdir -p /var/www/wordpress

# Set permissions
chown -R www-data:www-data /var/www/wordpress

# Test and restart Nginx
nginx -t
systemctl restart nginx

echo "Nginx installation completed"