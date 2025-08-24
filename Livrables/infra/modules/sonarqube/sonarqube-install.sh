# modules/sonarqube/sonarqube-install.sh
#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y wget curl unzip software-properties-common

# Install Java 17
apt-get install -y openjdk-17-jdk

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /etc/environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Configure PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Create SonarQube database and user
sudo -u postgres psql <<EOF
CREATE USER sonarqube WITH PASSWORD '${db_password}';
CREATE DATABASE sonarqube OWNER sonarqube;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
\q
EOF

# Configure PostgreSQL for SonarQube
echo "listen_addresses = 'localhost'" >> /etc/postgresql/14/main/postgresql.conf
echo "host sonarqube sonarqube 127.0.0.1/32 md5" >> /etc/postgresql/14/main/pg_hba.conf

systemctl restart postgresql

# Create sonarqube user
useradd -m -s /bin/bash sonarqube

# Download and install SonarQube
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip
unzip sonarqube-10.3.0.82913.zip
mv sonarqube-10.3.0.82913 sonarqube
chown -R sonarqube:sonarqube /opt/sonarqube

# Configure SonarQube
cat > /opt/sonarqube/conf/sonar.properties <<EOF
sonar.jdbc.username=sonarqube
sonar.jdbc.password=${db_password}
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.path.data=/opt/sonarqube/data
sonar.path.temp=/opt/sonarqube/temp
EOF

# Set system limits
cat >> /etc/security/limits.conf <<EOF
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOF

# Configure sysctl
cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF

sysctl -p

# Create systemd service
cat > /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOF

# Enable and start SonarQube
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install SSM Agent
snap install amazon-ssm-agent --classic
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

echo "SonarQube installation completed. Access it at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
echo "Default credentials: admin/admin"