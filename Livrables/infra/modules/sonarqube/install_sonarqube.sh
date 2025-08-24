#!/bin/bash

# Exit on error
set -e

# Load configuration file
SONARQUBE_DB_USER=sonar
SONARQUBE_DB_PASSWORD=sonarpass
SONARQUBE_DB_NAME=sonarqube
SONARQUBE_DB_PORT=5432
SONARQUBE_VERSION=9.9.8.100196
SONARQUBE_HTTP_PORT=9000

echo "Installing java and dependencies"
sudo apt update -y
sudo apt install -y openjdk-17-jdk wget unzip zip gnupg
echo "java and dependencies installed"

# Set vm.max_map_count
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Installing postgresql"

sudo apt update -y
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

echo "Installing postgresql done"

echo "Creating database for sonarqube"

sudo -u postgres psql <<EOF
CREATE USER $SONARQUBE_DB_USER WITH ENCRYPTED PASSWORD '$SONARQUBE_DB_PASSWORD';
CREATE DATABASE $SONARQUBE_DB_NAME OWNER $SONARQUBE_DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $SONARQUBE_DB_NAME TO $SONARQUBE_DB_USER;
EOF

echo "database for sonarqube created good job !"

echo "Downloading sonarqube"

cd /opt/
sudo curl -LO https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
sudo unzip -q sonarqube-${SONARQUBE_VERSION}.zip
sudo mv sonarqube-${SONARQUBE_VERSION} sonarqube
sudo groupadd -f sonar
sudo useradd -d /opt/sonarqube -g sonar sonar || true
sudo chown -R sonar:sonar /opt/sonarqube

echo "sonarqube downloaded and ready to configure"

echo "Configuring sonarqube"

sudo tee /opt/sonarqube/conf/sonar.properties > /dev/null <<EOF
sonar.jdbc.username=${SONARQUBE_DB_USER}
sonar.jdbc.password=${SONARQUBE_DB_PASSWORD}
sonar.jdbc.url=jdbc:postgresql://localhost/${SONARQUBE_DB_NAME}
sonar.web.host=0.0.0.0
sonar.web.port=${SONARQUBE_HTTP_PORT}
EOF

echo "Creating sonarqube service"

sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

echo "sonarqube service created well done !"

echo "Starting sonarqube service"

sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

echo "Installation succesfully done ! access : http://<votre-ip>:${SONARQUBE_HTTP_PORT}"