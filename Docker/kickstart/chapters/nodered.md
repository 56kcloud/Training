## 4.0 Overview NodeRed and Docker
NodeRed is a flow-based programming tool based on NodeJs. The interface allows for easily dragging and dropping nodes and wiring them together. The real power of NodeRed is when it is combined with Docker. Docker allows easily to provison services which NodeRed can connect to.

In this chapter we will cover the basics of running NodeRed inside of a Docker container. Once we have accomplished the deplyoment of NodeRed with Docker we will then add a MongoDB database which we will connect to from inside NodeRed.

To get started, let's run the following in our terminal:
```
$ docker run -it -p 1880:1880 --name mynodered nodered/node-red-docker
```

We can now access the NodeRed UI via `http://<hostip>:1880`

### 4.1 Configuring Node-RED
Great! Let's configure the Node-RED container and add a node:


```
# Open a shell in the container
docker exec -it mynodered /bin/bash

# Once inside the container, npm install the nodes in /data
cd /data
npm install node-red-node-smooth
exit
```

Hit `Ctrl-p` `Ctrl-q` to detach from the container. 

### 4.2 Persisting Data
In the last section, you saw a lot of Docker-specific jargon which might be confusing to some. So before you go further, let's clarify some terminology that is used frequently in the Docker ecosystem.


### 4.3 Building Custom Images

Creating a new Docker image, using the public Node-RED images as the base image, allows you to install extra nodes during the build process.

Create a file called Dockerfile with the content:

```
 FROM nodered/node-red-docker
 RUN npm install node-red-node-twitter
```

Run the following command to build the image:

```
 docker build -t mynodered:<tag> .
```

That will create a Node-RED image that includes the wordpos nodes.


### 4.4 Building a NodeRed Stack
In the Docker Swarm Chapter, we linked containers together using the Docker compose file.

For example, if you have a container that provides an MQTT broker container called mybroker, you can run the Node-RED container with the link parameter to join the two:

```
docker run -it -p 1880:1880 --name mynodered --link mybroker:broker nodered/node-red-docker
```

This will make broker a known hostname within the Node-RED container that can be used to access the service within a flow, without having to expose it outside of the Docker host.

We will now create a Docker compose stack using the Dockerfile from section 1.3.

1. Create a directory called nodered and change to the nodered directory
2. Create a file named `Dockerfile` in this directory with the following code:

```
 FROM nodered/node-red-docker
 RUN npm install node-red-node-twitter
 RUN npm install node-red-node-mongodb
```

1. Create a file name `docker-compose.yml`
2. Copy the below text into a file named `docker-compose.yml`


```
version: '3.1'
networks:
  node-red:

services:
 nodered:
   build: .
   ports:
     - "1880:1880"
   volumes:
     - ./data:/data
     - ./public:/home/nol/node-red-static
   links:
    - mongodb:mongodb
   networks:
    - node-red

 mongodb:
   image: mongo
   ports:
     - "27017:27017"
   networks:
     - node-red
```

* Run the command from the CLI: `docker-compose up`


## 4.5 Configuring Node-RED to see the new services
Now, we will walk through how Node-RED can use the new MongoDB

Access Node-Red `http://<hostip>:1880`


## Next Steps
For the next step in the tutorial, head over to [5.0 Deploying an InfluxDB Stack](./influxdb.md)