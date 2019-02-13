# predix-edge-ref-app

Predix Edge Reference App uses Predix UI Components, Polymer 2 and Node-Red.  

This project helps you with the developer life-cycle of creating, testing, and deploying a Predix Edge application.

It contains the UI code as well as all the scripts needed to run the dependent Docker containers.

Please follow the [tutorial](https://www.predix.io/resources/tutorials/journey.html#2593) to install and run the Predix Edge Reference App.



## Containers
The application consists of several Docker Containers, some from the Predix Edge team some for the Edge Reference App:

- **Predix Edge Data Broker** - a messaging queue with pub/sub topics using MQTT
- **OPCUA Simulator** - an OPCUA simulator that creates data consumed by the Predix Edge OPCUA Adapter
- **Predix Edge OPCUA Adapter** - receives OPCUA protocol, converts to Predix Time Series format and puts messages on a Topic
- **Edge Ref App Node Red** - Intercepts the messages to allow you to add JavaScript functions in the data flow, then puts message on a Topic
- **Predix Edge Time Series Cloud Gateway** - receives the Time Series topic messages and sends them to the Predix Cloud
- **Edge Ref App Node.js Polymer2 UI** - A UI to teach you how it all works and a Reference App UI using Predix UI and Polymer 2

## Modes of running, testing and deploying

You can run the application locally in Docker. And then test the App in a Predix Edge OS Virtual Machine running in VMWare Fusion.  Finally, you upload the application as a tar ball to the Predix Edge Manager.  From there you can deploy to the Predix Edge OS VM or to all your production devices.

1. Local Docker - All Containers from [Docker Hub](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=predix&starCount=0)
1. Local Docker - All Containers from [Docker Hub](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=predix&starCount=0), except UI running via Gulp (for interactive development)
1. In Predix Edge OS VM
1. Push tar to Edge Manager, then deploy to Predix Edge OS VM or production device.

## Predix Edge OS

The Predix Edge OS VM or Predix Edge OS running directly on a device has three components automatically inside of it.  This affects how we have to run and test things.

- **Edge Agent**, which talks to Edge Manager, running as a process on the OS
- **Predix Edge Technician Console** - a helpful UI app running in a Docker container that helps with administrative or registration tasks.
- **Predix Edge Data Broker** - a MQTT Topic Queue application running in a Docker container.

## How to run docker containers locally

Docker Swarm uses a command called Docker Stack (a set of containers) to manage several containers that make up an application.  Because the Predix Edge OS has the Predix Edge Data Broker running inside of it we separate our application in to two stacks.

Stack 1:
- Predix Edge Data Broker - docker-compose-edge-broker.yml

Stack 2:
- All other containers - docker-compose-local.yml(when running in local docker) or docker-compose.yml (when running in Predix Edge OS)

### Download the containers to your local repo

Using a browser visit and log in with your Predix account.  GE Users will use SSO Login.
```sh
https://artifactory.predix.io/artifactory/webapp/#/home
```

Navigate to the Artifacts and download and untar the following files, changing to the most recent version folder.
```sh
 PREDIX-EXT/predix-edge/2_1_0/os/predix-edge-broker-aarch64-20180917-1.0.2.tar.gz
 PREDIX-EXT/predix-edge/2_1_0/apps/adapters/predix-edge-opc-ua-adapter-aarch64-20180919-1.1.0.tar.gz
 PREDIX-EXT/predix-edge/2_1_0/apps/gateway/predix-edge-cloud-gateway-aarch64-20180919-1.1.0.tar.gz
```

Untar each file
```sh
 tar xvfz $imageTarFile
```

Load each one into your local Docker repository
```sh
 docker load -i images.tar
```

Get the edge-node-red and edge-ref-app ui from the Docker Repository
```sh
 docker pull hub.docker.com/predixadoption/predix-edge-node-red:latest
 docker pull hub.docker.com/predixadoption/predix-edge-ref-app:latest
```

### Build if needed (say you made a change)

If you need to create the Image locally, use docker build.  But first check the versions in various files and make sure they match.  
```sh
 cat version.json
 cat package.json
 cat docker-compose-local.yml | grep image
```

Next build the docker image which reads the Dockerfile and places it in the local images repo:

If you are behind a corporate proxy server, use the proxy switches or remove them if not needed for your situation.

Change the version in the command below to match

```sh
docker build --no-cache --build-arg https_proxy --build-arg no_proxy= --build-arg http_proxy -t predixadoption/predix-edge-ref-app:latest .
```

### Start the containers

Now start the Predix Edge Data Broker

```sh
docker stack deploy -c docker-compose-edge-broker.yml predix-edge-broker
```

Since we are mounting a volume from inside the container, back to the ./config and ./data directories, the app needs privileges to your local config and data dir.  Since the users on your computer are different than the inside the container, this is needed.  Of course, later, when you run the app from the context of the Predix Edge OS docker, not your local docker, the privileges have to be set as needed.

```sh
chmod -R 777 data
```

Now start the edge-ref-app containers
```sh
docker stack deploy --resolve-image never -c docker-compose-local.yml edge-ref-app
```

### Validate they started

Now check out what you did:
```sh
docker stack ls
```

```sh
docker stack ps edge-ref-app
```
or
```sh
docker ps
```

```sh
docker logs <id of process from docker ps output>
```

## How to Debug a container if it is not launching with Docker stack command

Docker Stack uses the Swarm manager which is really a production utility that brings dying containers back up if they fail.  This is common in cloud environments which have a load balancer and a set of containers it is doing round-robin to.  

However, if one of the containers has a bug or an environmental problem it is quite difficult to figure out because the container is not staying up long enough to view the log.  For example, in some cases the file permissions might not allow the code inside the container to create a file or mkdir a directory when using a mounted volume back to the folder you are currently in.

There are a few tricks you can use to solve this.

### Trick #1 - add an entry_point.sh entry to the docker-compose.

```sh
entrypoint: ["sh", "-c", "sleep 500000"]
```

Then have a look around

```sh
docker exec -it id-of-container-here /bin/sh
```

### Trick #2 - launch the container manually

Remove the stack

```sh
docker stack rm edge-ref-app
```

Comment the misbehaving service and restart the stack

```sh
docker stack deploy -c docker-compose-local.yml edge-ref-app
```

Comment it back in (sometimes you have to comment out the Network entry in the docker-compose-xxxx.yml).   Now run the single container:

```sh
docker-compose -f docker-compose-local.yml up name-of-the-service-in-docker-compose-file-here
```

For more ideas, look here:
https://medium.com/@betz.mark/ten-tips-for-debugging-docker-containers-cde4da841a1d

##
## How to develop the UI application locally (not downloaded from Docker Hub and in a docker container)

Say you want to make some changes to the UI application and run it locally for development purposes.

1. First, comment out the **edge-ref-app** section of the **docker-compose-local.yml**.  

Then remove and deploy the app.
```sh
docker stack rm edge-ref-app
```
Then add it back

```sh
docker stack deploy -c docker-compose-local.yml edge-ref-app
```

2. Use npm to install dev tools & server.  Bower will install polymer & browser components.  Use gulp to compile sass files.
```
$ npm install
$ bower install
$ gulp compile:sass
```

### Viewing Your UI Application

```
$ gulp
```
This will watch for changes in .scss files, and compile them to css.
Also, if app.js changes, the server will restart.
Open http://127.0.0.1:5000 in your browser

### Building Your Application

```
$ gulp dist
```

This will create builds of your application in the `build/` directory, optimized to be served in production. You can also serve the built versions by running this:

```
$ gulp --dist
```

## Running Tests

```
$ polymer test
```

Your application is already set up to be tested via [web-component-tester](https://github.com/Polymer/web-component-tester). Run `polymer test` to run your application's test suite locally.

## View the application

Open http://127.0.0.1:5000 in your browser.

## How to save the app for deployment to Edge manager

The [tutorial](https://www.predix.io/resources/tutorials/journey.html#2593) explains how to deploy to Predix Edge Reference App and provides a more comprehensive script that enrolls your device and other tasks needed to see the app uploaded to Edge Manager.

For experienced developers, here are the commands to save the app as a tar.

```bash
docker save -o images.tar predixadoption/predix-edge-ref-app:latest predixadoption/predix-edge-opcua-simulator:latest dtr.predix.io/predix-edge/protocol-adapter-opcua:amd64-latest dtr.predix.io/predix-edge/cloud-gateway:amd64-latest
```

```bash
tar -czvf app.tar.gz images.tar docker-compose.yml
```
Create the config.zip file.

Note, you only want to zip up the actual files, not the config folder that contains the files.

```bash
cd config
zip -X -r ../config.zip *.json
cd ../
```

## How to push the edge-ref-app to the Docker Hub

You will want to fork this repo and push to your own Docker registry such as Docker Hub or if you have permissions to the Predix DTR.

If you need to create the Image locally, use docker build.  But first check the versions in various files and make sure they match.  
```sh
 cat version.json
 cat package.json
 cat docker-compose-local.yml | grep image
```
Next build the docker image:

This command uses the Dockerfile to create the docker container so it can be uploaded to Docker Hub.  If you are behind a corporate proxy server, use the proxy switches or remove them if not needed for your situation.

Now log in to the Docker Hub. Create a dockerhub account if you do not have one. [Docker Hub Signup](https://hub.docker.com/signup)

```sh
docker login -u <username> -p <password>
```

Build predix-edge-ref-app docker image using proxy. Change 'predixadoption' to your Docker Organization which is usually your username.

```sh
docker build --no-cache -t predixadoption/predix-edge-ref-app:latest --build-arg https_proxy --build-arg no_proxy= --build-arg http_proxy .
```

Build predix-edge-ref-app docker image without proxy. Change 'predixadoption' to your Docker Organization which is usually your username.

```sh
docker build --no-cache -t predixadoption/predix-edge-ref-app:latest .
```

Now Push the docker image to the Docker Hub.

```sh
docker push <Docker Organization>/predix-edge-ref-app:latest
```

[![Analytics](https://predix-beacon.appspot.com/UA-82773213-1/predix-edge-ref-app/readme?pixel)](https://github.com/PredixDev)
