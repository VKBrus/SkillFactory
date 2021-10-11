sudo apt update
sudo apt upgrade
sudo apt install  -y mc net-tools nano

sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8 LC_TIME="ru_RU.UTF-8"
sudo timedatectl set-timezone Europe/Samara

sudo swapoff -a
# Необходимо закомментировать строку со "swapfile"
sudo nano /etc/fstab

sudo nano /etc/hosts
sudo hostnamectl set-hostname master  
#sudo hostnamectl set-hostname worker1
#sudo hostnamectl set-hostname worker2

sudo reboot -h now

#--- Установка Docker
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common acl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

#Проверка
sudo docker run hello-world

sudo groupadd docker
sudo usermod -aG docker $USER

newgrp docker 

docker run hello-world
#Если есть проблемы с правами на каталог .docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

#sudo mkdir /etc/docker
ll /etc/docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl status docker
sudo systemctl enable docker


#--- Установка Artifactory OSS

docker pull docker.bintray.io/jfrog/artifactory-oss:latest
docker images
docker run --name artifactory -d -p 8081:8081 docker.bintray.io/jfrog/artifactory-oss:latest

# ---  на другой машине
docker run --name artifactory-pro-nginx -d -p 8000:80 -p 8443:443 docker.bintray.io/jfrog/nginx-artifactory-oss:latest

# --- Adding Self Signed Certificates to Java cacerts
docker run --name artifactory -d -p 8081:8081 -v /home/bob/cert_test docker.bintray.io/jfrog/artifactory-oss:latest

