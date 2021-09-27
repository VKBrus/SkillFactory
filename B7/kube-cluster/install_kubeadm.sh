sudo apt update
sudo apt upgrade
sudo apt install  -y mc net-tools nano

sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8 LC_TIME="ru_RU.UTF-8"
sudo timedatectl set-timezone Europe/Samara

sudo swapoff -a
# Необходимо закомментировать строку со "swapfile"
sudo nano /etc/fstab

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

#--- Установка Docker
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

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


#--- Установка Kubernetes

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

#На master
sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=172.17.0.1 

# 172.17.0.1 - откуда взялся?
## --- или 130.193.58.32 (внешний) или 10.244.0.3 (внутренний) ???

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Alternatively, if you are the root user, you can run:
export KUBECONFIG=/etc/kubernetes/admin.conf

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

# --- только на master
sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"


#Then you can join any number of worker nodes by running the following on each as root:
# --- На worker
sudo kubeadm join 172.17.0.1:6443 --token 6mid0v.br7zdb08jrvjzkmc --discovery-token-ca-cert-hash sha256:f270599d60449d08a0ba3701906a0e0b4af88cbc91dca6405369e37587166c52 

# 172.17.0.1 - откуда взялся?
## --- или 130.193.58.32 (внешний) или 10.244.0.3 (внутренний) ???
===

#Если же пробовать Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
# ???
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# --------  Если выбираете плагин Calico
curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml

# ---------


sudo systemctl start kubelet
sudo systemctl enable kubelet 


# ---

# Размышления из разных мест
export KUBERNETES_MASTER=https://10.244.0.10:6443   #Надо ли вообще?

kubectl taint nodes --all node-role.kubernetes.io/master-



#Проверка
kubectl get all -o wide

kubectl get nodes -o wide

kubectl get pods -o wide

kubectl get po -A

kubectl get events -A

#kubectl describe node/pod <node/pod-name>
#kubectl logs <node/pod-name>
#kubectl <pod-name> -c <container-name>
#kubectl exec -it <>

#sudo journalctl -u kubelet | tail
#sudo journalctl -u kubelet -xn | less
#sudo kubectl get events | grep bad
#kubectl get events | grep bad
#kubectl describe node b
kubectl describe po --all-namespaces

#----------

При настройке кластера с помощью «kubeadm init» следует помнить несколько моментов, и это четко задокументировано на сайте Kubernetes kubeadm cluster create : 
https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

"kubeadm reset", если вы уже создали предыдущий кластер
Удалите папку ".kube" из домашнего или корневого каталога.
(Также остановка kubelet с помощью systemctl обеспечит плавную настройку)
sudo systemctl stop kubelet


Отключите свопинг на машине навсегда, особенно если вы перезагружаете свою Linux-систему.
sudo swapoff -a
# Необходимо закомментировать строку со "swapfile"
sudo nano /etc/fstab


И не забывайте, установите надстройку сети pod в соответствии с инструкциями, приведенными в добавлении на сайте (не на сайте Kubernetes).
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

Следуйте инструкциям по инициализации, указанным в командном окне kubeadm.
Если все эти шаги выполнены правильно, ваш кластер будет работать правильно.

И не забудьте выполнить следующую команду, чтобы включить планирование в созданном кластере:

kubectl taint nodes --all node-role.kubernetes.io/master-

О том, как установить из-за прокси, вы можете найти это полезным:
https://stackoverflow.com/questions/45580788/how-to-install-kubernetes-cluster-behind-proxy-with-kubeadm

