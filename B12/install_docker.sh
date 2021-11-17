sudo apt update
sudo apt upgrade
sudo apt autoremove
sudo apt autoclean
sudo apt clean
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

lsmod | grep br_netfilter
sudo modprobe br_netfilter
lsmod | grep overlay
sudo modprobe overlay

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

#sudo useradd vladimir -p vladimir_sf

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
#sudo usermod -aG docker vladimir
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


------
# ИЛИ 

sudo apt install docker.io
sudo apt install docker-compose
