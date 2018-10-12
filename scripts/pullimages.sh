#!/bin/bash
HOME_DIR=$(pwd)

if [[ -e docker-compose-edge-broker.yml ]]; then
		for  image in $(grep "image:" docker-compose-edge-broker.yml | awk -F" " '{print $2}' | tr -d "\"");
		do
			 docker pull $image
		done
fi
if [[ -e docker-compose-local.yml ]]; then
		for  image in $(grep "image:" docker-compose-local.yml | awk -F" " '{print $2}' | tr -d "\"");
		do
			 docker pull $image
		done
fi
