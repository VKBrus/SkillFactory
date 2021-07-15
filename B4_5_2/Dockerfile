#Загрузить базовый образ Ubuntu
FROM php:7.2-apache

MAINTAINER Vladimir Brusentsov <vk.brusencov@yandex.ru>
ENV TZ=Europe/Samara

# Указываем рабочую папку
WORKDIR /var/www/html
# Копируем все файлы проекта в контейнер
COPY . /var/www/html
EXPOSE 80


