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

