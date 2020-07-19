#!/bin/sh

cd /home/ubuntu
mkdir -p /home/ubuntu/postgre-data

rm -frd /home/ubuntu/extra-addons
mkdir -p /home/ubuntu/extra-addons
cd /home/ubuntu/extra-addons
curl -o master.zip -sSL https://github.com/hectord137/odoo-addons/archive/master.zip
sudo apt-get install -y unzip
unzip -o master.zip
mv -f odoo-addons-master/* ./
rm -frd master.zip

cd /home/ubuntu
apt-get remove -y docker docker-engine docker.io containerd runc
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

curl -sSL "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

apt-get update
apt-get install -y awscli

rm -frd /home/ubuntu/odoo-config
mkdir -p /home/ubuntu/odoo-config
cd /home/ubuntu/odoo-config
aws s3 cp s3://odoo-conf/odoo.conf ./

rm -frd /home/ubuntu/nginx-data
mkdir -p /home/ubuntu/nginx-data
mkdir -p /home/ubuntu/nginx-data/ssl
mkdir -p /home/ubuntu/nginx-data/logs
cd /home/ubuntu/nginx-data
aws s3 cp s3://odoo-conf/default.conf ./

cd /home/ubuntu/nginx-data/ssl
aws s3 cp s3://ssl-cert-hdap/ ./ --recursive

cd /home/ubuntu
aws s3 cp s3://odoo-conf/docker-compose.yml ./
#docker-compose rm -f -s -v
#docker-compose up -d --force-recreate
docker-compose up -d
docker-compose exec web pip3 install paramiko
docker-compose exec web pip3 install pykhipu
docker-compose restart
