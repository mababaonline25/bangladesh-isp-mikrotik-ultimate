#!/bin/bash
###############################################################################
# FreeRADIUS Installation Script for Ubuntu/Debian
# Version: 5.0.0
###############################################################################

set -e

echo "================================================"
echo "FreeRADIUS Installation Script"
echo "Version: 5.0.0"
echo "================================================"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install FreeRADIUS and dependencies
echo "Installing FreeRADIUS..."
apt-get install -y freeradius freeradius-mysql freeradius-utils \
    mysql-server mysql-client libmysqlclient-dev \
    apache2 php php-mysql php-pear php-gd php-curl \
    build-essential make gcc

# Install daloRADIUS dependencies
echo "Installing daloRADIUS dependencies..."
pear install DB

# Create RADIUS database
echo "Creating RADIUS database..."
mysql -u root -p <<EOF
CREATE DATABASE IF NOT EXISTS radius;
GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost' IDENTIFIED BY 'radius-password';
GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'%' IDENTIFIED BY 'radius-password';
FLUSH PRIVILEGES;
EOF

# Import MySQL schema
echo "Importing MySQL schema..."
mysql -u root -p radius < mysql-schema.sql

# Configure FreeRADIUS
echo "Configuring FreeRADIUS..."
cp radiusd.conf /etc/freeradius/3.0/radiusd.conf
cp clients.conf /etc/freeradius/3.0/clients.conf
cp default-radius /etc/freeradius/3.0/sites-enabled/default

# Configure FreeRADIUS with MySQL
echo "Configuring FreeRADIUS with MySQL..."
cat > /etc/freeradius/3.0/mods-enabled/sql <<EOF
sql {
    driver = "rlm_sql_mysql"
    dialect = "mysql"
    server = "localhost"
    port = 3306
    login = "radius"
    password = "radius-password"
    radius_db = "radius"
}
EOF

# Restart FreeRADIUS
echo "Restarting FreeRADIUS..."
systemctl restart freeradius
systemctl enable freeradius

# Install daloRADIUS
echo "Installing daloRADIUS..."
cd /var/www/html
wget https://github.com/lirantal/daloradius/archive/refs/tags/1.4.5.tar.gz
tar -xzf 1.4.5.tar.gz
mv daloradius-1.4.5 daloradius
cd daloradius

# Configure daloRADIUS
echo "Configuring daloRADIUS..."
cp daloradius.conf.php.sample daloradius.conf.php
sed -i 's/db_host = "localhost"/db_host = "localhost"/g' daloradius.conf.php
sed -i 's/db_user = "root"/db_user = "radius"/g' daloradius.conf.php
sed -i 's/db_pass = ""/db_pass = "radius-password"/g' daloradius.conf.php
sed -i 's/db_name = "radius"/db_name = "radius"/g' daloradius.conf.php

# Import daloRADIUS schema
echo "Importing daloRADIUS schema..."
mysql -u root -p radius < contrib/db/mysql-daloradius.sql

# Set permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/daloradius
chmod -R 755 /var/www/html/daloradius

# Configure Apache
echo "Configuring Apache..."
cat > /etc/apache2/sites-available/daloradius.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@yourdomain.com
    DocumentRoot /var/www/html/daloradius
    ServerName radius.yourdomain.com
    
    <Directory /var/www/html/daloradius>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2ensite daloradius
a2enmod rewrite
systemctl restart apache2

# Configure firewall
echo "Configuring firewall..."
ufw allow 1812/udp
ufw allow 1813/udp
ufw allow 1814/udp
ufw allow 80/tcp
ufw allow 443/tcp

echo "================================================"
echo "FreeRADIUS Installation Complete!"
echo "================================================"
echo "RADIUS Server: localhost"
echo "RADIUS Ports: 1812 (Auth), 1813 (Accounting)"
echo "daloRADIUS URL: http://$(hostname -I | awk '{print $1}')/daloradius"
echo "Default daloRADIUS Login: administrator / radius"
echo "================================================"
echo "Please change the default passwords!"
echo "================================================"