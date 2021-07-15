#Создать образ docker
docker build -t vkbrus_apache .

#Запустить image
docker run -p 80:80 vkbrus_apache

#Перейти в браузер
http://localhost:80


#После экспериментов можно "прибраться" от мусора
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)


