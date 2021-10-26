#!/bin/bash

echo "Enter server Address:"
read SRV_ADDRESS
echo "Enter SSH port (default 22)"
read SRV_PORT
echo "Enter username:"
read USERNAME
echo "Enter password:"
read -s PASSWORD

echo "Add data to Prometheus"
cd ../
echo "    - targets: ['$SRV_ADDRESS:9100']" >> ./docker/prometheus/prometheus.yml
docker container restart prometheus

echo "Connect to server..."

ssh -T $USERNAME@$SRV_ADDRESS -p $SRV_PORT << ENDSSH

sudo -S su
$PASSWORD

apt-get update && apt-get install docker.io -y

echo "install Docker compose"
curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-\$(uname -s)-\$(uname -m)"  -o /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
sleep 5
echo "Creating compose file ..."
mkdir /srv/docker
cat > /srv/docker/docker-compose.yml << EOF
version: '3.2'
services:
    node-exporter:
        image: prom/node-exporter
        volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
            - /:/rootfs:ro
        command:
            - --path.procfs=/host/proc
            - --path.sysfs=/host/sys
            - --collector.filesystem.ignored-mount-points
            - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
        ports:
            - 9100:9100
        restart: always
        deploy:
            mode: global
EOF
echo "Compose file created"

echo "Add docker autostart"
cat > /etc/systemd/system/docker-compose-app.service << EOF
# /etc/systemd/system/docker-compose-app.service

[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
WorkingDirectory=/srv/docker
ExecStart=/usr/local/bin/docker-compose up
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0
Restart=on-failure
StartLimitIntervalSec=60
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

systemctl enable docker-compose-app

sysctl net.ipv4.conf.all.forwarding=1
iptables -P FORWARD ACCEPT

echo "Start container with Node exporter"
docker-compose up -d

ENDSSH

echo "Node exporter started. Go to Grafana for monitoring."