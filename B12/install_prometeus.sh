#--- Установка Prometeus на сервере
cd ~
mkdir B12
cd B12
touch docker-compose.yml
nano docker-compose.yml
# --- содержимое
# version: '3.3'
# services:
#     prometheus:
#         image: prom/prometheus:latest
#         volumes:
#             - ./prometheus:/etc/prometheus/
#         command:
#             - --config.file=/etc/prometheus/prometheus.yml
#         ports:
#             - 10.244.0.23:9090:9090
#         restart: always
# 
#     node-exporter:
#         image: prom/node-exporter
#         volumes:
#             - /proc:/host/proc:ro
#             - /sys:/host/sys:ro
#             - /:/rootfs:ro
#         hostname: monitoring
#         command:
#             - --path.procfs=/host/proc
#             - --path.sysfs=/host/sys
#             - --collector.filesystem.ignored-mount-points
#             - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
#         ports:
#             - 10.244.0.23:9100:9100
#			  - 10.244.0.21:9100:9100
#         restart: always
#
#     blackbox-exporter:
#           image: prom/blackbox-exporter
#           ports:
#             — 10.244.0.23:9115:9115
#           restart: always
#           volumes:
#             - ./blackbox:/config
#           command: --config.file=/config/blackbox.yml

mkdir prometheus
cd prometheus
touch prometheus.yml
nano prometheus.yml
# --- содержимое
# scrape_configs:
#   - job_name: node
#     scrape_interval: 5s
#     static_configs:
#     - targets: ['node-exporter:9100']

# - job_name: blackbox
#     metrics_path: /probe
#     params:
#       module: [http_2xx]
#     static_configs:
#       - targets:
#         - https://lms.skillfactory.ru
#     relabel_configs:
#       - source_labels: [__address__]
#         target_label: __param_target
#       - source_labels: [__param_target]
#         target_label: instance
#       - target_label: __address__
#         replacement: blackbox-exporter:9115

cd ../B12
mkdir blackbox
cd blackbox
touch config.yml
nano config.yml
# --- Конфиг blackbox/config.yml
#modules:
#  http_2xx:
#    http:
#      no_follow_redirects: false
#      preferred_ip_protocol: ip4
#      valid_http_versions:
#      - HTTP/1.1
#      - HTTP/2
#      valid_status_codes: []
#    prober: http
#    timeout: 10s




cd ..
sudo docker-compose up -d
# ---  Проверка
curl 10.244.0.23:9100/metrics


# --- Установка Grafana
git clone https://github.com/digitalstudium/grafana-docker-stack.git
sudo docker swarm init
# Swarm initialized: current node (qzii2wmmfifkbpbgxnhqol7hl) is now a manager.
#
# To add a worker to this swarm, run the following command:
#
#     docker swarm join --token SWMTKN-1-0r5tqq3s4m5u8g08ji3f4rwgllmak9u0djyvosguiafdy83ir1-3yyibq9el9kc0mewer6bsfroo 10.244.0.23:2377
# 
# To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
# Для 
# sudo docker swarm join-token manager

sudo docker stack deploy -c grafana-docker-stack/docker-compose.yml monitoring

sudo docker stats
#CONTAINER ID   NAME                                                   CPU %     MEM USAGE / LIMIT     MEM %     NET I/O          BLOCK I/O    PIDS
#9b06409252f1   monitoring_grafana.1.329g7f64ybgqvmunykou0oow5         0.11%     24.57MiB / 7.775GiB   0.31%     68.1kB / 718kB   0B / 123kB   11
#6013f530a9f5   monitoring_node-exporter.1.7vxawmh0kw5l5wfpglkjsvxm2   0.00%     3.305MiB / 7.775GiB   0.04%     1.06kB / 0B      0B / 0B      6
#7ac3cbf795e1   b12_prometheus_1                                       0.00%     27.03MiB / 7.775GiB   0.34%     5.12MB / 530kB   0B / 0B      10
#3754205005e8   b12_blackbox-exporter_1                                0.00%     10.14MiB / 7.775GiB   0.13%     1.98MB / 180kB   0B / 0B      10
#ebc52fba0459   b12_node-exporter_1                                    0.00%     10.15MiB / 7.775GiB   0.13%     247kB / 5.51MB   0B / 0B      7                           0.00%     27.59MiB / 7.775GiB   0.35%     2.57MB / 130kB    0B / 0B       9
# sudo docker container port 7ac3cbf795e1
#9090/tcp -> 10.244.0.23:9090
# sudo docker container port 3754205005e8
#9115/tcp -> 10.244.0.23:9115
#sudo docker container port ebc52fba0459
#9100/tcp -> 10.244.0.23:9100

netstat -ntlp
#Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
#tcp        0      0 10.244.0.23:9100        0.0.0.0:*               LISTEN      -                   
#tcp        0      0 127.0.0.1:45265         0.0.0.0:*               LISTEN      -                   
#tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -                   
#tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -                   
#tcp        0      0 10.244.0.23:9115        0.0.0.0:*               LISTEN      -                   
#tcp        0      0 10.244.0.23:9090        0.0.0.0:*               LISTEN      -                   
#tcp6       0      0 :::22                   :::*                    LISTEN      -                   
#tcp6       0      0 :::3000                 :::*                    LISTEN      -                   
#tcp6       0      0 :::2377                 :::*                    LISTEN      -                   
#tcp6       0      0 :::7946                 :::*                    LISTEN      -

sudo docker-compose ps
#                Name                        Command               State             Ports           
#---------------------------------------------------------------------------------------------
#b12_blackbox-exporter_1   /bin/blackbox_exporter --c ...   Up      10.244.0.23:9115->9115/tcp
#b12_node-exporter_1       /bin/node_exporter --path. ...   Up      10.244.0.23:9100->9100/tcp
#b12_prometheus_1          /bin/prometheus --config.f ...   Up      10.244.0.23:9090->9090/tcp

sudo docker-compose images
#     Container                Repository          Tag       Image Id       Size  
#-----------------------------------------------------------------------------------
#b12_blackbox-exporter_1   prom/blackbox-exporter   latest   c9e462ce1ee4   20.89 MB
#b12_node-exporter_1       prom/node-exporter       latest   95ff6611a45b   20.9 MB 
#b12_prometheus_1          prom/prometheus          latest   c10e9cbf22cd   194.1 MB

sudo docker ps
#CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS          PORTS                        NAMES
#9b06409252f1   grafana/grafana:8.0.6-ubuntu   "/run.sh"                10 minutes ago   Up 10 minutes   3000/tcp                     monitoring_grafana.1.329g7f64ybgqvmunykou0oow5
#6013f530a9f5   prom/node-exporter:v1.2.0      "/bin/node_exporter …"   10 minutes ago   Up 10 minutes   9100/tcp                     monitoring_node-exporter.1.7vxawmh0kw5l5wfpglkjsvxm2
#7ac3cbf795e1   prom/prometheus:latest         "/bin/prometheus --c…"   43 minutes ago   Up 43 minutes   10.244.0.23:9090->9090/tcp   b12_prometheus_1
#3754205005e8   prom/blackbox-exporter         "/bin/blackbox_expor…"   43 minutes ago   Up 43 minutes   10.244.0.23:9115->9115/tcp   b12_blackbox-exporter_1
#ebc52fba0459   prom/node-exporter             "/bin/node_exporter …"   43 minutes ago   Up 43 minutes   10.244.0.23:9100->9100/tcp   b12_node-exporter_1

sudo nano /var/lib/docker/volumes/monitoring_prom-configs/_data/prometheus.yml

sudo docker ps | grep prometheus
sudo docker kill -s SIGHUP c3ac3d9c4983
#ИЛИ
sudo docker ps | grep prometheus | awk '{print $1}' | xargs sudo docker kill -s SIGHUP



sudo docker run -d --name=grafana -p 3000:3000 grafana/grafana-enterprise:8.2.5-ubuntu
