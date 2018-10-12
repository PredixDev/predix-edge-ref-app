#!/bin/bash

docker build -t predixadoption/predix-edge-node-red:latest . --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy
