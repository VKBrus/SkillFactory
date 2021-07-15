<<<<<<< HEAD
#Загрузить базовый образ Ubuntu
FROM php:7.2-apache

MAINTAINER Vladimir Brusentsov <vk.brusencov@yandex.ru>
ENV TZ=Europe/Samara

# Указываем рабочую папку
WORKDIR /var/www/html
# Копируем все файлы проекта в контейнер
COPY . /var/www/html
EXPOSE 80


=======
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y locales mc stop nano


###nodejs
###COPY server.js /
### CMD ["/usr/bin/node", "server.js"]
>>>>>>> d911a66f7034bb1da81ea91b0cac8e3751b70397
