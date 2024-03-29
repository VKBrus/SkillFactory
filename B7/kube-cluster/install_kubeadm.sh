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


#--- Установка Kubernetes

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl


#--- Натсройка кластера

#На master
#sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=172.17.0.1 
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 > cluster_initialized.txt --ignore-preflight-errors=...
cat cluster_initialized.txt

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Alternatively, if you are the root user, you can run:
#export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > pod_network_setup.txt
cat pod_network_setup.txt

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

# --- только на master
#sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

sudo kubeadm token list
sudo kubeadm token create --print-join-command

#Then you can join any number of worker nodes by running the following on each as root:
# --- На worker
sudo kubeadm join 10.244.0.32:6443 --token 7zi2vu.t3cn7nbevh6u3rok --discovery-token-ca-cert-hash sha256:3a6592bd5059f95b8c36bd9180202c86bf70e27d1213027fee1c7bdc3e7cf3cc
#sudo kubeadm join 10.244.0.3:6443 --token uhk38r.yjf68xhje9ky101z --discovery-token-ca-cert-hash sha256:459c25819a4cd0d95f6c069f094978baf5cf5e780880ad3f2ee8824793120606
=======

#Если же пробовать Flannel
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
# ???
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# --------  Если выбираете плагин Calico
#curl https://docs.projectcalico.org/manifests/calico.yaml -O
#kubectl apply -f calico.yaml

# ---------

sudo systemctl status kubelet
sudo systemctl start kubelet
sudo systemctl enable kubelet 

# ---

# Размышления из разных мест
export KUBERNETES_MASTER=https://10.244.0.10:6443   #Надо ли вообще?

kubectl taint nodes --all node-role.kubernetes.io/master-


#Проверка
sudo chmod 755 -R ~/.kube/cache
kubectl get all -o wide

kubectl get nodes -o wide

kubectl get pods -o wide

kubectl get po -A

kubectl get events -A

kubectl describe node/pod <node/pod-name>
kubectl logs <node/pod-name>
kubectl <pod-name> -c <container-name>
kubectl exec -it <>

sudo journalctl -u kubelet | tail
sudo journalctl -u kubelet -xn | less
sudo kubectl get events | grep bad
kubectl get events | grep bad
kubectl describe node master
kubectl describe po --all-namespaces

# Проверка здоровья
kubectl get componentstatuses


# Посмотреть и сохранить манифесты в файл
kubectl -n kube-system get configmap kubeadm-config -o yaml > kubeadm-config.yaml
kubectl get nodes -o yaml > nodes-config.yaml


# ++++++++++++++++++++++++++
#Как установить Kubernetes Dashboard
#Kubernetes Dashboard — это универсальный веб-интерфейс для кластеров Kubernetes. 
#Он позволяет пользователям управлять приложениями, работающими в кластере, и устранять их неполадки, а также управлять самим кластером.

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml

#Создать dashboard-adminuser.yaml
touch dashboard-adminuser.yaml
kubectl apply -f dashboard-adminuser.yaml

#ИЛИ
cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f - 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

# Нужно редактировать файл конфиг kubectl и изменить тип сервиса на LoadBalancer
kubectl -n kubernetes-dashboard edit svc kubernetes-dashboard
# Вот так
#   spec:
#       type: LoadBalancer
#       externalIPs:
#       - 192.168.0.10

# Рестарт может помочь
kubectl -n kube-system rollout restart deployment/coredns


#Следующая команда предоставит нам привязанный порт к сервису панели мониторинга.
kubectl -n kube-system get services

# следующая команда, чтобы получить токен.
kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token

eyJhbGciOiJSUzI1NiIsImtpZCI6IktVSVptVTh4dnBJZ0ItVHlWZmZaVjFQQkpmdUtQLWs5d1M2WkJhak5nRncifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJuYW1lc3BhY2UtY29udHJvbGxlci10b2tlbi1uNzlsZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJuYW1lc3BhY2UtY29udHJvbGxlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImUyMDY4MWQzLWIxOTQtNGY4Ny04YzY5LWVmMjU3NjU3ZDYyYiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpuYW1lc3BhY2UtY29udHJvbGxlciJ9.kakGboRc2kLPd-fBTDcXIkQeVCZBEYn3hfPeHRWeCHwDtBDdUkCmqgLrE0JEJsNvaxjv-YvGadcKIcvbyFwnn8b0jCYFjbFLRhlyAKHq8GIQbt97G4FTVaH1W9YOHcHbgHpdJJpvodqIb9gQES7bkrbGaOkW2vPDAih7GAFW0LMnzL3O_95CZuyLSHGoudi9LVNqw-jIbvWmfeulRa4xHZcz3bbKwoeOvIYejVydzSBjLRR0ZYRmWx1TzCq3jF4alZIj3TmGw6Sr0mgNhiPu5hCOzv4uqcSuFuAQJaISRHinVoEhlr5R5RPc1UZeh1YX-6rSyflnaNIqm9AcLFaWKA

# !!!!!!!!!!! Нужно проброс порта делать:
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 --address 0.0.0.0
# после этого подключаться к дашборду по https://178.154.215.115 (внешний адрес):8443
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#!!! Получите доступ к панели мониторинга по адресу https://[master_node_ip]:[port] и предоставьте токен для входа. !!!


# Из задания (немного некорректная формулировка)
# Открыть Dashboard UI по ссылке
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
#Используйте файл $HOME/.kube/config для входа в UI.


# Или на другой машине - с пробросом портов
kubectl proxy&
kubectl create serviceaccount <bob>
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=default:<bob>
kubectl get secret
kubectl describe secret bob-token-6pjnp
ssh -L 9999:127.0.0.1:8001 -N -f -l <bob> master


# Или - другой путь к Dashboard
# запускать от пользователя
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm install --namespace monitoring --create-namespace -f manifests/dashboard-values.yml kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
kubectl apply -f manifests/dashboard-admin.yml
kubectl -n monitoring describe secret $(kubectl -n monitoring get secret | grep admin-user | awk '{print $1}')
kubectl port-forward -n monitoring $(kubectl get pods -n monitoring -l "app.kubernetes.io/name=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}") 9090
# Перейдите по адресу http://localhost:9090 и используйте представленный токен для авторизации

#
#
#
#
#

#  ---------- Советы разных людей --- разные способы решения разных этапов
# Подсеть поднимал Calico
# я стартовал кластер вот так:
kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=10.129.0.4


#----------
# Если надо все заново

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


------
Рекомендации от ментора 29.09.2021


Vladislav Markov  16:04
посмотрел бегло - пока не трогайте ничего - ещё гляну. Не вижу пакета acl - я установил
кластер готов

vladimir@master:~$ kubectl get nodes
NAME      STATUS   ROLES                  AGE   VERSION
master    Ready    control-plane,master   15m   v1.22.2
worker1   Ready    <none>                 68s   v1.22.2
worker2   Ready    <none>                 32s   v1.22.2


user: vladimir
pass: vladimir_sf

Не могу сказать в чем была проблема, вы просто пропустили какой-то шаг видимо. Я все сделал по инструкции что завалялась у меня в виду готового ansible сценария. Сделал руками быстро. Ничего не шаманил.

Не стоял только пакет acl

В остальном - докер везде стоит - это норм

репо кубера прописана - это тоже норм

kubelet, kubeadm, kubectl - опять же были вами уже установлены - что тоже норм :легкая_улыбка:

те все водные были верны кроме пакета acl

А далее просто пару команд:
kubeadm init --pod-network-cidr=10.244.0.0/16 > cluster_initialized.txt под рутом
копируете конфиг из /etc/kubernetes/admin.conf в /home/vladimir/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > pod_network_setup.txt
kubeadm token create --print-join-command     -  под рутом
на нодах выполняете join - команду из п.4

И все...
Обычно все это оборачивают в shell скрипт или Ansible, ваши однокурсники
