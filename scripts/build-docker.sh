#!/bin/bash

docker build -t predixedge/predix-edge-ref-app:latest . --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy

docker pull dtr.predix.io/predix-edge/predix-edge-broker:amd64-1.0.2

docker stack deploy -c docker-compose-edge-broker.yml predix-edge-broker

docker pull dtr.predix.io/predix-edge/cloud-gateway:amd64-1.1.0

docker pull dtr.predix.io/predix-edge/cloud-gateway:amd64-1.1.0

docker pull predixedge/predix-edge-node-red:1.0.21

docker stack deploy -c docker-compose-local.yml predix-edge-ref-app

docker service ls

docker service logs predix-edge-ref-app_edge-ref-app

sleep 30
