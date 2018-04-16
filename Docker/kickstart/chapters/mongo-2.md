# Deploying MongoDB

In this lab you'll learn how to deploy MongoDB with Docker.

You will complete the following steps as part of this lab.

- [Task 1 - Build Custom Image](#Task_1)
- [Task 2 - Building a NodeRed Stack](#Task_2)
- [Task 3 - Configuring Node-RED](#Task_3)
- [Task 4 - Replicated MongoDB](#Task_4)
- [Task 5 - Cleanup](#Task_4)

In this lab the terms *service task* and *container* are used interchangeably.
In all examples in the lab a *service tasks* is a container that is running as
part of a service.

## Overview NodeRed, MongoDB, and Docker
NodeRed is a flow-based programming tool based on NodeJs. The interface allows for easily dragging and dropping nodes and wiring them together. The real power of NodeRed is when it is combined with Docker. Docker allows easily to provison services which NodeRed can connect to.

In this chapter we will cover the basics of running NodeRed inside of a Docker container. Once we have accomplished the deplyoment of NodeRed with Docker we will then add a MongoDB database which we will connect to from inside NodeRed.

To get started, let's run the following in our terminal:
```
$ docker run -it -p 1880:1880 --name mynodered nodered/node-red-docker
```

We can now access the NodeRed UI via `http://<hostip>:1880`


### <a name="Task_1"></a>Task 1: Building Custom Images

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


### <a name="Task_2"></a>Task 2: Building a NodeRed Stack
In the Docker Swarm Chapter, we linked containers together using the Docker compose file.

For example, if you have a container that providesis your APP and you would like to connect it to a MongoDB to persist the data. In this example, we link the Node-RED container with MongoDB so node-red can store data:

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
   volumes:
      - /path/to/mongodb-persistence:/bitnami
   ports:
     - "27017:27017"
   networks:
     - node-red
```

* Run the command from the CLI: `docker-compose up`


## <a name="Task_3"></a>Task 3: Configuring Node-RED to see the new services
Now, we will walk through how Node-RED can use the new MongoDB

Access Node-Red `http://<hostip>:1880`


## <a name="Task_4"></a>Task 4: Replicated MongoDB
To setup a MongoDB cluster is quite easy. To understand how a MongoDB cluster works review the [MongoDB replication documentaiton](https://docs.mongodb.com/manual/replication/)

```
services:
  mongodb-primary:
    image: 'bitnami/mongodb:latest'
    environment:
      - MONGODB_REPLICA_SET_MODE=primary
      - MONGODB_ROOT_PASSWORD=password123
      - MONGODB_REPLICA_SET_KEY=replicasetkey123
    volumes:
      - 'mongodb_master_data:/bitnami'

  mongodb-secondary:
    image: 'bitnami/mongodb:latest'
    depends_on:
      - mongodb-primary
    environment:
      - MONGODB_REPLICA_SET_MODE=secondary
      - MONGODB_PRIMARY_HOST=mongodb-primary
      - MONGODB_PRIMARY_PORT_NUMBER=27017
      - MONGODB_PRIMARY_ROOT_PASSWORD=password123
      - MONGODB_REPLICA_SET_KEY=replicasetkey123

  mongodb-arbiter:
    image: 'bitnami/mongodb:latest'
    depends_on:
      - mongodb-primary
    environment:
      - MONGODB_REPLICA_SET_MODE=arbiter
      - MONGODB_PRIMARY_HOST=mongodb-primary
      - MONGODB_PRIMARY_PORT_NUMBER=27017
      - MONGODB_PRIMARY_ROOT_PASSWORD=password123
      - MONGODB_REPLICA_SET_KEY=replicasetkey123

volumes:
  mongodb_master_data:
    driver: local
```

In the above example we can easily scale our MongoDB cluster:

```
$ docker-compose scale mongodb-primary=1 mongodb-secondary=3 mongodb-arbiter=1
```

The above command scales up the number of secondary nodes to 3

## <a name="Task_5"></a>Task 5: Cleanup

This is the final cleanup where we will delete all the containers, networks, and volumes from your Docker Host. **Only if you want to**

1. First stop the running MongoDB stack

```
$ docker-compose rm
```

2. Prune Docker of all containers, images, networks, and basically everything else.

```
$ docker system prune
WARNING! This will remove:
        - all stopped containers
        - all networks not used by at least one container
        - all dangling images
        - all build cache
Are you sure you want to continue? [y/N]
``


## Next Steps
[Additional Ressources](./README.md)