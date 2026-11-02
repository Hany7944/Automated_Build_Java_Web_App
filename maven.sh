#!/bin/bash

# Run as root
sudo -i

# Update package list and install EPEL release
echo "Installing EPEL release..."
yum install epel-release -y

# Install Git, Maven, and Wget
echo "Installing Git, Maven, and Wget..."
dnf -y install git maven wget

# Code build & deploy
# Download source code
echo "Downloading source code..."
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

# Build code
echo "Building code..."
mvn install

echo "Maven setup and deployment is complete."


