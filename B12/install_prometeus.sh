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
#         restart: always
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


# --- Установка Graphana
git clone https://github.com/digitalstudium/grafana-docker-stack.git
sudo docker swarm init
# Swarm initialized: current node (j5dednod6epcd2c9tne3b1y47) is now a manager.
#
# To add a worker to this swarm, run the following command:
#
#     docker swarm join --token SWMTKN-1-0po8qczdhmrseaevwhcnzpvfb10q0v3hyqbqi7i39hckkf7g55-9xyqn1y7slno6w1r6s5a410mt 10.244.0.23:2377
# 
# To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

sudo docker stack deploy -c grafana-docker-stack/docker-compose.yml monitoring

sudo docker stats
#CONTAINER ID   NAME                                                   CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O    PIDS
#de845d53324b   b12_prometheus_1                                       0.00%     0B / 0B               0.00%     0B / 0B           0B / 0B      0
#c4357357e0c1   b12_blackbox-exporter_1                                0.00%     2.812MiB / 7.775GiB   0.04%     1.17kB / 0B       0B / 0B      6
#16647c4f886e   b12_node-exporter_1                                    0.00%     6.219MiB / 7.775GiB   0.08%     2.69kB / 62.7kB   0B / 0B      8
#c6b2b3d308df   monitoring_node-exporter.1.o89jgxoa6jqoiubyxzu8w9f0y   0.00%     3.227MiB / 7.775GiB   0.04%     516B / 0B         0B / 0B      6
#c3ac3d9c4983   monitoring_prometheus.1.w2mvvqhqcr4y0xwo7wca4smbl      0.00%     24.4MiB / 7.775GiB    0.31%     176B / 0B         0B / 4.1kB   9                                     0.00%     27.59MiB / 7.775GiB   0.35%     2.57MB / 130kB    0B / 0B       9
# sudo docker container port 442bda30965c
# 9090/tcp -> 127.0.0.1:9090
# sudo docker container port 2251e63a2b62
# 9100/tcp -> 127.0.0.1:9100

netstat -ntlp
#Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
#tcp        0      0 10.244.0.23:9100        0.0.0.0:*               LISTEN      -                   
#tcp        0      0 127.0.0.1:45231         0.0.0.0:*               LISTEN      -                   
#tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -                   
#tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -                   
#tcp        0      0 10.244.0.23:9115        0.0.0.0:*               LISTEN      -                   
#tcp6       0      0 :::9090                 :::*                    LISTEN      -                   
#tcp6       0      0 :::2377                 :::*                    LISTEN      -                   
#tcp6       0      0 :::7946                 :::*                    LISTEN      -                   
#tcp6       0      0 :::22                   :::*                    LISTEN      -                   
#tcp6       0      0 :::3000                 :::*                    LISTEN      -        

sudo docker-compose ps
#       Name                      Command               State            Ports          
#---------------------------------------------------------------------------------------
#b12_blackbox-exporter_1   /bin/blackbox_exporter --c ...   Up       10.244.0.23:9115->9115/tcp
#b12_node-exporter_1       /bin/node_exporter --path. ...   Up       10.244.0.23:9100->9100/tcp
#b12_prometheus_1          /bin/prometheus --config.f ...   Exit 2

sudo docker-compose images
#     Container            Repository        Tag       Image Id       Size  
#---------------------------------------------------------------------------
#b12_blackbox-exporter_1   prom/blackbox-exporter   latest   c9e462ce1ee4   20.89 MB
#b12_node-exporter_1       prom/node-exporter       latest   0fafea149859   21.17 MB
#b12_prometheus_1          prom/prometheus          latest   c10e9cbf22cd   194.1 MB

sudo docker ps
#CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS          PORTS                        NAMES
#7bc5d275b667   grafana/grafana:8.0.6-ubuntu   "/run.sh"                12 minutes ago   Up 12 minutes   3000/tcp                     monitoring_grafana.1.n5bkioecxymqr86rn10z1ssd2
#c3ac3d9c4983   prom/prometheus:v2.28.1        "/bin/prometheus --c…"   12 minutes ago   Up 12 minutes   9090/tcp                     monitoring_prometheus.1.w2mvvqhqcr4y0xwo7wca4smbl
#c6b2b3d308df   prom/node-exporter:v1.2.0      "/bin/node_exporter …"   12 minutes ago   Up 12 minutes   9100/tcp                     monitoring_node-exporter.1.o89jgxoa6jqoiubyxzu8w9f0y
#c4357357e0c1   prom/blackbox-exporter         "/bin/blackbox_expor…"   15 minutes ago   Up 15 minutes   10.244.0.23:9115->9115/tcp   b12_blackbox-exporter_1
#16647c4f886e   prom/node-exporter             "/bin/node_exporter …"   15 minutes ago   Up 15 minutes   10.244.0.23:9100->9100/tcp   b12_node-exporter_1

nano /var/lib/docker/volumes/monitoring_prom-configs/_data/prometheus.yml

sudo docker ps | grep prometheus
sudo docker kill -s SIGHUP c3ac3d9c4983


