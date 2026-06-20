📄 docs/RADIUS-SETUP-GUIDE.md
markdown
# RADIUS Setup Guide

## FreeRADIUS Configuration for ISP

---

## 1. Introduction

This guide explains how to set up FreeRADIUS with MySQL for ISP authentication and accounting. The setup includes:
- FreeRADIUS server installation
- MySQL database configuration
- daloRADIUS web management panel
- MikroTik integration
- Billing system integration

---

## 2. Prerequisites

### 2.1 Hardware Requirements
- Ubuntu 20.04 or 22.04 LTS Server
- Minimum 2GB RAM
- Minimum 20GB Storage
- Static IP Address

### 2.2 Software Requirements
- MySQL 5.7 or 8.0
- Apache 2.4
- PHP 7.4 or 8.0
- FreeRADIUS 3.0
- daloRADIUS 1.4+

---

## 3. Installation

### 3.1 System Update
```bash
sudo apt update
sudo apt upgrade -y
3.2 Install MySQL
bash
sudo apt install mysql-server mysql-client -y
sudo mysql_secure_installation
3.3 Install FreeRADIUS
bash
sudo apt install freeradius freeradius-mysql freeradius-utils -y
3.4 Install Apache and PHP
bash
sudo apt install apache2 php php-mysql php-pear php-gd php-curl php-mbstring php-xml -y
3.5 Install daloRADIUS Dependencies
bash
sudo pear install DB
sudo apt install git wget unzip -y
4. Database Configuration
4.1 Create RADIUS Database
bash
sudo mysql -u root -p
sql
CREATE DATABASE radius;
CREATE USER 'radius'@'localhost' IDENTIFIED BY 'radius-password';
GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';
CREATE USER 'radius'@'%' IDENTIFIED BY 'radius-password';
GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'%';
FLUSH PRIVILEGES;
EXIT;
4.2 Import Database Schema
bash
mysql -u root -p radius < /usr/share/freeradius/mysql/schema.sql
4.3 Import daloRADIUS Schema
bash
mysql -u root -p radius < /var/www/html/daloradius/contrib/db/mysql-daloradius.sql
5. FreeRADIUS Configuration
5.1 Configure SQL Module
bash
sudo nano /etc/freeradius/3.0/mods-enabled/sql
conf
sql {
    driver = "rlm_sql_mysql"
    dialect = "mysql"
    server = "localhost"
    port = 3306
    login = "radius"
    password = "radius-password"
    radius_db = "radius"
}
5.2 Configure Clients
bash
sudo nano /etc/freeradius/3.0/clients.conf
conf
client main_router {
    ipaddr = 192.168.20.1
    secret = radius-secret
    shortname = main-router
    nas_type = mikrotik
}

client backup_router {
    ipaddr = 10.1.200.2
    secret = radius-secret
    shortname = backup-router
    nas_type = mikrotik
}

client pop_router {
    ipaddr = 10.1.201.0/24
    secret = radius-secret
    shortname = pop-routers
    nas_type = mikrotik
}
5.3 Configure Default Site
bash
sudo nano /etc/freeradius/3.0/sites-enabled/default
conf
authorize {
    preprocess
    chap
    mschap
    suffix
    eap {
        ok = return
    }
    sql
    expiration
    logintime
    pap
}

authenticate {
    auth_log
    chap
    mschap
    digest
    eap
    pap
}

accounting {
    detail
    unix
    sql
    exec
}
5.4 Restart FreeRADIUS
bash
sudo systemctl restart freeradius
sudo systemctl enable freeradius
6. daloRADIUS Setup
6.1 Download daloRADIUS
bash
cd /var/www/html
sudo git clone https://github.com/lirantal/daloradius.git
sudo mv daloradius daloradius
cd daloradius
6.2 Configure daloRADIUS
bash
sudo cp daloradius.conf.php.sample daloradius.conf.php
sudo nano daloradius.conf.php
php
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
6.3 Set Permissions
bash
sudo chown -R www-data:www-data /var/www/html/daloradius
sudo chmod -R 755 /var/www/html/daloradius
sudo chmod 644 /var/www/html/daloradius/daloradius.conf.php
6.4 Configure Apache
bash
sudo nano /etc/apache2/sites-available/daloradius.conf
conf
<VirtualHost *:80>
    ServerAdmin admin@yourdomain.com
    DocumentRoot /var/www/html/daloradius
    ServerName radius.yourdomain.com
    
    <Directory /var/www/html/daloradius>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
bash
sudo a2ensite daloradius.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
6.5 Default Login
text
URL: http://your-server-ip/daloradius
Username: administrator
Password: radius
7. MikroTik RADIUS Configuration
7.1 Add RADIUS Server
bash
/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot
/radius add address=10.1.200.3 secret=radius-secret service=ppp,hotspot
7.2 Configure RADIUS Settings
bash
/radius set [find] authentication-port=1812
/radius set [find] accounting-port=1813
/radius set [find] timeout=5s
/radius set [find] retries=3
/radius incoming set accept=yes port=3799
7.3 Enable RADIUS for PPPoE
bash
/ppp aaa set use-radius=yes accounting=yes interim-update=5m
/ppp aaa set default-profile=radius-default
7.4 Test RADIUS
bash
/radius test username=testuser password=test123
8. User Management
8.1 Add User via CLI
bash
mysql -u root -p radius
sql
-- Add user
INSERT INTO radcheck (username, attribute, op, value) 
VALUES ('customer1', 'Cleartext-Password', ':=', 'pass123');

-- Add user to group
INSERT INTO radusergroup (username, groupname, priority) 
VALUES ('customer1', '10Mbps', 1);

-- View users
SELECT * FROM radcheck;
SELECT * FROM radusergroup;
8.2 Add User via daloRADIUS
Login to daloRADIUS

Go to "Users" -> "List Users"

Click "Add New User"

Fill in user details

Select group/package

Save

8.3 Bulk User Creation
bash
#!/bin/bash
for i in {1..100}
do
    mysql -u root -p radius -e "
    INSERT INTO radcheck (username, attribute, op, value) 
    VALUES ('customer$i', 'Cleartext-Password', ':=', 'pass$i');
    INSERT INTO radusergroup (username, groupname, priority) 
    VALUES ('customer$i', '10Mbps', 1);"
done
9. Billing Integration
9.1 Create Billing Database```sql
CREATE TABLE billing_plans (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
speed_down VARCHAR(20),
speed_up VARCHAR(20),
price DECIMAL(10,2),
validity_days INT,
data_limit BIGINT,
status ENUM('active','inactive')
);

CREATE TABLE billing_invoices (
id INT AUTO_INCREMENT PRIMARY KEY,
username VARCHAR(64),
amount DECIMAL(10,2),
paid_amount DECIMAL(10,2),
due_date DATE,
status ENUM('pending','paid','overdue'),
created_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

text

### 9.2 Auto Invoice Generation
```bash
#!/bin/bash
# /usr/local/bin/generate-invoices.sh

mysql -u root -p radius <<EOF
INSERT INTO billing_invoices (username, amount, due_date)
SELECT 
    u.username,
    p.price,
    DATE_ADD(CURDATE(), INTERVAL p.validity_days DAY)
FROM radcheck u
JOIN billing_plans p ON u.groupname = p.name
WHERE u.attribute = 'Cleartext-Password';
EOF
9.3 Expiry Management
sql
-- Check expired users
SELECT u.username, i.due_date
FROM radcheck u
JOIN billing_invoices i ON u.username = i.username
WHERE i.status = 'overdue'
AND i.due_date < CURDATE();

-- Disable expired users
UPDATE radcheck
SET attribute = 'Expiry-Date',
    value = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
WHERE username IN (
    SELECT username FROM billing_invoices 
    WHERE status = 'overdue' 
    AND due_date < CURDATE() - INTERVAL 7 DAY
);
10. Advanced Configuration
10.1 RadSec (Secure RADIUS)
bash
# Generate certificates
openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout /etc/freeradius/3.0/certs/server.key \
    -out /etc/freeradius/3.0/certs/server.pem

# Configure RadSec
sudo nano /etc/freeradius/3.0/radsec.conf
conf
radsec {
    enabled = yes
    server {
        ipv4 = 0.0.0.0
        port = 2083
    }
    tls {
        certificate_file = ${certdir}/server.pem
        private_key_file = ${certdir}/server.key
        ca_file = ${certdir}/ca.pem
    }
}
10.2 CoA (Change of Authorization)
bash
# Enable CoA
/radius coa set enabled=yes port=1700
/radius coa add address=10.1.200.2 secret=radius-secret

# Disconnect user
/radius coa disconnect username=customer1
10.3 Failover Configuration
bash
/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot
/radius add address=10.1.200.3 secret=radius-secret service=ppp,hotspot
/radius set [find] dead-time=5m
11. Monitoring
11.1 View RADIUS Status
bash
# FreeRADIUS status
sudo systemctl status freeradius

# View logs
sudo tail -f /var/log/freeradius/radius.log

# Active sessions
mysql -u root -p radius -e "SELECT * FROM radacct WHERE acctstoptime IS NULL;"
11.2 RADIUS Statistics
bash
# Total users
mysql -u root -p radius -e "SELECT COUNT(*) FROM radcheck;"

# Active sessions
mysql -u root -p radius -e "SELECT COUNT(*) FROM radacct WHERE acctstoptime IS NULL;"

# Bandwidth usage
mysql -u root -p radius -e "
SELECT 
    username,
    SUM(acctinputoctets) AS total_download,
    SUM(acctoutputoctets) AS total_upload
FROM radacct
WHERE acctstarttime > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY username;"
12. Troubleshooting
12.1 RADIUS Not Responding
bash
# Check service
sudo systemctl status freeradius

# Check ports
sudo netstat -tulpn | grep 1812

# Test RADIUS
radtest testuser test123 localhost 0 testing123
12.2 Authentication Fails
bash
# Check logs
sudo tail -f /var/log/freeradius/radius.log

# Check SQL connectivity
mysql -u radius -p -h localhost radius

# Check user in database
mysql -u root -p radius -e "SELECT * FROM radcheck WHERE username='testuser';"
12.3 Accounting Not Working
bash
# Check accounting configuration
sudo cat /etc/freeradius/3.0/mods-enabled/sql | grep -A 20 "accounting {"

# Check database
mysql -u root -p radius -e "DESCRIBE radacct;"

# Test accounting
radclient -x 127.0.0.1 acct testing123
13. Security Best Practices
13.1 Secure Database
bash
# Use strong passwords
# Limit access to localhost
# Use SSL for connections
# Regular backups
13.2 Secure FreeRADIUS
bash
# Disable unused modules
# Use RadSec for encryption
# Implement rate limiting
# Monitor logs regularly
13.3 Secure daloRADIUS
bash
# Use HTTPS
# Enable 2FA
# Use strong admin password
# Limit login attempts
# Regular updates
14. Backup & Recovery
14.1 Backup Database
bash
#!/bin/bash
# /usr/local/bin/backup-radius.sh

BACKUP_DIR="/var/backups/radius"
DATE=$(date +%Y%m%d)

mysqldump -u root -p radius > $BACKUP_DIR/radius-$DATE.sql
gzip $BACKUP_DIR/radius-$DATE.sql

# Keep 30 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
14.2 Backup Configuration
bash
#!/bin/bash
# /usr/local/bin/backup-radius-config.sh

BACKUP_DIR="/var/backups/radius"
DATE=$(date +%Y%m%d)

tar -czf $BACKUP_DIR/radius-config-$DATE.tar.gz \
    /etc/freeradius/ \
    /var/www/html/daloradius/daloradius.conf.php
14.3 Restore Database
bash
gunzip radius-20240101.sql.gz
mysql -u root -p radius < radius-20240101.sql
<div align="center"> 🔐 [Back to Top](#radius-setup-guide) </div> ```