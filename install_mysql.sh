#!/bin/bash

# Exit on error
set -e

MYSQL_VERSION=${1:-"8.0"}
MYSQL_ROOT_PASSWORD=${2:-$(openssl rand -base64 32)}

echo "Installing MySQL ${MYSQL_VERSION}..."

# Install MySQL
apt-get update
apt-get install -y mysql-server-${MYSQL_VERSION}

# Secure MySQL installation
mysql --user=root <<_EOF_
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
_EOF_

# Create WordPress database and user
WP_DB="wordpress"
WP_USER="wordpress"
WP_PASS=$(openssl rand -base64 32)

mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" <<_EOF_
CREATE DATABASE ${WP_DB};
CREATE USER '${WP_USER}'@'localhost' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON ${WP_DB}.* TO '${WP_USER}'@'localhost';
FLUSH PRIVILEGES;
_EOF_

# Save credentials
cat > /root/.wp_db_credentials <<EOL
DB_NAME=${WP_DB}
DB_USER=${WP_USER}
DB_PASSWORD=${WP_PASS}
DB_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
EOL

chmod 600 /root/.wp_db_credentials

echo "MySQL ${MYSQL_VERSION} installation completed"