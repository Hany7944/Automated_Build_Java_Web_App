#!/bin/bash

# Switch to root user
# sudo -i

# Update package list and install EPEL release
echo "Installing EPEL release..."
yum install epel-release -y

# Install MariaDB and Git
echo "Installing MariaDB and Git..."
yum install git expect mariadb-server -y

# Start and enable MariaDB service
echo "Starting and enabling MariaDB service..."
systemctl start mariadb
systemctl enable mariadb

# Run mysql_secure_installation script automatically
echo "Securing MariaDB..."

expect <<EOF
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\r"
expect "Switch to unix_socket authentication \[Y/n\]"
send "Y\r"
expect "Change the root password? \[Y/n\]"
send "Y\r"
expect "New password:"
send "admin123\r"
expect "Re-enter new password:"
send "admin123\r"
expect "Remove anonymous users? \[Y/n\]"
send "Y\r"
expect "Disallow root login remotely? \[Y/n\]"
send "Y\r"
expect "Remove test database and access to it? \[Y/n\]"
send "Y\r"
expect "Reload privilege tables now? \[Y/n\]"
send "Y\r"
expect eof
EOF

# Configure MariaDB: Create database and user
echo "Configuring MariaDB database and user..."
mysql -u root -padmin123 <<MYSQL_SCRIPT
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Download source code and initialize database
echo "Cloning source code and initializing database..."
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql

# Restart MariaDB service
echo "Restarting MariaDB service..."
systemctl restart mariadb

# Start and configure the firewall to allow access to MariaDB on port 3306
# echo "Configuring firewall..."
# systemctl start firewalld
# systemctl enable firewalld
# firewall-cmd --zone=public --add-port=3306/tcp --permanent
# firewall-cmd --reload

echo "MariaDB setup is complete."

