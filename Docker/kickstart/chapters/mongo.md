# Deploying MongoDB

In this lab you'll learn how to deploy MongoDB with Docker.

## Overview MongoDB and Docker

MongoDB is a free and open-source cross-platform document-oriented database program. Classified as a NoSQL database program, MongoDB uses JSON-like documents with schemas.

To get started, let's run the following in our terminal:

```
$ docker run \
    -v /data/files/path:/bitnami \
    bitnami/mongodb:latest
```

Now, Mongo is running and is available for internal connections on port 27017 

### Persisting Data in Mongo

Running a MongoDB container without a persistent data storage will not persist your data if you delete your container. In this section we add a `VOLUME` which will be used to persist data and be always available.

1. Create a file name `docker-compose.yml`
2. Copy the below text into a file named `docker-compose.yml`


```
version: '3.1'
networks:
  mongo-net:

services:
  mongodb:
    image: 'bitnami/mongodb:latest'
    volumes:
      - /path/to/mongodb-persistence:/bitnami
    ports:
      - "27017:27017"
    environment:
      - MONGODB_USERNAME=my_user
      - MONGODB_PASSWORD=password123
      - MONGODB_DATABASE=my_database
```

* Run the command from the CLI: `docker-compose up`


## Configuring Node-RED to see the new services
Now, we will walk through how Node-RED can use the new MongoDB

Access Node-Red `http://<hostip>:1880`


## Next Steps
For the next step in the tutorial, head over to [MongoDB connected to an APP](./mongo-2.md)
