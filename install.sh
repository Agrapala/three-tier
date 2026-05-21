#!/bin/bash
set -e

# System update
apt-get update -y && apt-get upgrade -y

# Java (Jenkins dependency)
apt-get install -y openjdk-17-jdk

# Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" \
  | tee /etc/apt/sources.list.d/jenkins.list
apt-get update -y && apt-get install -y jenkins
systemctl enable jenkins && systemctl start jenkins

# Docker
apt-get install -y docker.io
systemctl enable docker && systemctl start docker
usermod -aG docker jenkins
usermod -aG docker ubuntu

# Terraform
apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor \
  -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update -y && apt-get install -y terraform

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sL \
  https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
apt-get install -y unzip && unzip awscliv2.zip
./aws/install

# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

# SonarQube (Docker container)
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community