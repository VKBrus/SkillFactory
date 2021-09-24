sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8 LC_TIME="ru_RU.UTF-8"
sudo timedatectl set-timezone Europe/Samara

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https:/packages.cloud.google.com/apt/doc/apt-key.gpg

sudo echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl start kubelet
sudo systemctl enable kubelet 

#__________--

sudo mkdir /etc/docker

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

sudo apt-get update

sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload

sudo systemctl restart docker

sudo systemctl enable docker


# -------

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#--------


sudo kubeadm init --apiserver-advertise-address=10.244.0.10 --pod-network-cidr=10.244.0.0/16  --ignore-preflight-errors=all

#To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Alternatively, if you are the root user, you can run:

#  export KUBECONFIG=/etc/kubernetes/admin.conf

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/


kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

#Then you can join any number of worker nodes by running the following on each as root:
# Выполнять на worker-нодах !!!
sudo kubeadm join 10.244.0.10:6443 --token npt6gi.1tzxuf0c316osdkv --discovery-token-ca-cert-hash sha256:6a270917e8b2cf0f0831e6ece414c88d7ab19fe55e207211d857f7cc930788db --ignore-preflight-errors=all

export KUBERNETES_MASTER=https://10.244.0.10:6443   #Надо ли вообще?

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
Отключите свопинг на машине навсегда, особенно если вы перезагружаете свою Linux-систему.
И не забывайте, установите надстройку сети pod в соответствии с инструкциями, приведенными в добавлении на сайте (не на сайте Kubernetes).
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

Следуйте инструкциям по инициализации, указанным в командном окне kubeadm.
Если все эти шаги выполнены правильно, ваш кластер будет работать правильно.

И не забудьте выполнить следующую команду, чтобы включить планирование в созданном кластере:

kubectl taint nodes --all node-role.kubernetes.io/master-

О том, как установить из-за прокси, вы можете найти это полезным:
https://stackoverflow.com/questions/45580788/how-to-install-kubernetes-cluster-behind-proxy-with-kubeadm


curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml

