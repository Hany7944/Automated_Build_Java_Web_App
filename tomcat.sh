#!/bin/bash

# Run as root
sudo -i

# Install Java
echo "Installing Java ..."
dnf -y install expect java-11-openjdk java-11-openjdk-devel 

# Download and extract Tomcat package
echo "Downloading and extracting Tomcat package..."
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz

# Add tomcat user
echo "Adding tomcat user..."
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

# Copy data to tomcat home directory
echo "Copying data to Tomcat home directory..."
# mkdir -p /usr/local/tomcat
cp -r apache-tomcat-9.0.75/*  /usr/local/tomcat/

# Make tomcat user owner of tomcat home directory
echo "Making tomcat user owner of Tomcat home directory..."
chown -R tomcat.tomcat /usr/local/tomcat

# Create tomcat systemd service file
echo "Creating tomcat systemd service file..."
cat <<EOL > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd files and start & enable tomcat service
echo "Reloading systemd files and starting & enabling tomcat service..."
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# Deploy artifact
echo "Deploy artifact and replace old ROOT.war by new one"
systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*

# Deploy artifact
echo "Deploying artifact..."
su - vagrant
expect <<EOF
spawn scp -o StrictHostKeyChecking=no vagrant@192.168.56.13:/home/vagrant/vprofile-project/target/vprofile-v2.war /home/vagrant/vprofile-v2.war
expect "vagrant@192.168.56.13's password:"
send "vagrant\r"
expect eof
EOF
sudo -i
cp /home/vagrant/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
chown -R tomcat.tomcat /usr/local/tomcat/webapps
systemctl restart tomcat


# Enabling the firewall and allowing port 8080 to access Tomcat
# echo "Enabling the firewall and allowing port 8080 to access Tomcat..."
# systemctl start firewalld
# systemctl enable firewalld
# firewall-cmd --zone=public --add-port=8080/tcp --permanent
# firewall-cmd --reload



