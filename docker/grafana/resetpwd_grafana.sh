#!/bin/bash

echo "Reset grafana password for user admin"

set container_id = docker ps -a | grep grafana | head -n1 | awk '{print $1;}'
echo "Enter new password:"
read -s PASSWORD

docker exec -ti $container_id  grafana-cli admin reset-admin-password $PASSWORD