#!/bin/bash

docker build -t predixadoption/predix-edge-node-red:latest . --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy

docker pull dtr.predix.io/predix-edge/predix-edge-mosquitto-amd64:latest

docker stack deploy -c docker-compose-edge-broker.yml predix-edge-broker

docker pull dtr.predix.io/predix-edge/protocol-adapter-opcua-amd64:latest

docker pull dtr.predix.io/predix-edge/cloud-gateway-timeseries-amd64:latest

docker pull predixadoption/predix-edge-node-red:latest

docker stack deploy -c docker-compose-local.yml predix-edge-ref-app

docker service ls

docker service logs predix-edge-ref-app_edge-ref-app

sleep 30
