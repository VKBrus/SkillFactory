# Посмотреть и сохранить манифесты в файл
kubectl -n kube-system get configmap kubeadm-config -o yaml > kubeadm-config.yaml
kubectl get nodes -o yaml > nodes-config.yaml

# Создание одиночного пода
kubectl run nginx-bob --image=nginx:latest --port=80

# сетевой доступ к созданному поду, создаем port-forward 
kubectl port-forward nginx-bob --address 0.0.0.0 8888:80

#открыть браузер и ввести адрес http://<IP-адрес мастера>:8888 — должна открыться страница приветствия для NGINX

# Создание yaml манифеста не создавая объектов
kubectl run nginx --image=nginx:latest --port=80 --restart=Never --dry-run=client -o yaml > create-pod-nginx.yaml


kubectl create deploy nginx-bob --image=nginx  --replicas=3 --dry-run=client -o yaml > nginx-bob-deployment.yml
kubectl apply -f nginx-bob-deployment.yml

# Предоставление доступа к модулю или развертыванию в службе
kubectl expose deployment nginx-bob --port=80 --type=ClusterIP --target-port=8888



kubectl create deploy nginx-bob --image=nginx  --replicas=27
kubectl expose deploy nginx-bob --port 80 --target-port 8888 --type LoadBalancer
kubectl port-forward replicaset.apps/nginx-bob-d75c4c4fd --address 0.0.0.0 8888:80

kubectl get all -o wide

kubectl delete deploy --all
kubectl delete svc --all
kubectl delete pod --all