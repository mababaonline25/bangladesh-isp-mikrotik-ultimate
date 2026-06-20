#!/bin/bash
###############################################################################
# daloRADIUS Installation Script
# Version: 5.0.0
###############################################################################

set -e

echo "================================================"
echo "daloRADIUS Installation Script"
echo "Version: 5.0.0"
echo "================================================"

# Check if FreeRADIUS is installed
if ! command -v radtest &> /dev/null; then
    echo "FreeRADIUS is not installed. Please run freeradius-install.sh first."
    exit 1
fi

# Install daloRADIUS
echo "Installing daloRADIUS..."
cd /var/www/html

# Download latest daloRADIUS
wget https://github.com/lirantal/daloradius/archive/refs/tags/1.4.5.tar.gz
tar -xzf 1.4.5.tar.gz
mv daloradius-1.4.5 daloradius
cd daloradius

# Configure daloRADIUS
echo "Configuring daloRADIUS..."
cp daloradius.conf.php.sample daloradius.conf.php

# Update configuration
cat > daloradius.conf.php <<'EOF'
<?php
$config['db_host'] = 'localhost';
$config['db_user'] = 'radius';
$config['db_pass'] = 'radius-password';
$config['db_name'] = 'radius';
$config['db_type'] = 'mysqli';
$config['base_path'] = '/var/www/html/daloradius';
$config['gui_theme'] = 'default';
$config['log_auth'] = true;
$config['log_auth_detail'] = true;
$config['log_acct'] = true;
$config['log_admin'] = true;
$config['auth_type'] = 'local';
$config['locale'] = 'en_US';
$config['timezone'] = 'Asia/Dhaka';
?>
EOF

# Import daloRADIUS schema
echo "Importing daloRADIUS schema..."
mysql -u root -p radius < contrib/db/mysql-daloradius.sql

# Set permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/daloradius
chmod -R 755 /var/www/html/daloradius
chmod 644 /var/www/html/daloradius/daloradius.conf.php

# Configure Apache for daloRADIUS
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

echo "================================================"
echo "daloRADIUS Installation Complete!"
echo "================================================"
echo "URL: http://$(hostname -I | awk '{print $1}')/daloradius"
echo "Default Login: administrator"
echo "Default Password: radius"
echo "================================================"
echo "Please change the default password!"
echo "================================================"