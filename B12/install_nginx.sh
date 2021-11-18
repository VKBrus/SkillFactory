#--- Установка nginx на VM2
cd ~
mkdir B12
cd B12
touch docker-compose.yml
nano docker-compose.yml
# --- содержимое
#version: '3.3'
#
#services:
#
#  nginx:
#    image: nginx
#    ports:
#      - 80:80
#    volumes:
#      - ./html:/usr/share/nginx/html

mkdir html
cd html
sudo touch index.html
sudo nano index.html
# --- содержимое
#<!DOCTYPE html>
#
#<html lang="ru">
#<head>
#<meta charset="UTF-8">
#<title>Docker-NGINX</title>
#</head>
#<body>
#Привет из Docker-NGINX для мониторинга VM2 в Grafana через Prometeus в VM1
#</body>
#</html>

sudo docker-compose up -d

### -- На VM2
git clone https://github.com/digitalstudium/grafana-docker-stack.git
sudo docker swarm init
#Swarm initialized: current node (xkulzblof7wv870vnn8xg99k7) is now a manager.
#
#To add a worker to this swarm, run the following command:
#
#    docker swarm join --token SWMTKN-1-2ie9fza1a8srezbx9juslopghvvtgl9fl2cj7fl61qutpvbv4t-1tz05lg8pqtogtav7sfh9v71o 10.244.0.21:2377
#
#To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

sudo docker stack deploy -c grafana-docker-stack/node-exporter.yml node-exporter
