## 5.0 Getting Started with InfluxDB
InfluxDb is a powerful Timeseries Database solution. In this chapter we will deploy an InfluxDB stack. We will then focus configuring the InfluxDB stack and learn the process of upgrading to newer versions.

This stack consists of three components

**[cAdvisor](https://registry.hub.docker.com/u/google/cadvisor/)** - Google has been using containers for quite sometime and created cAdvisor to help monitor their infrastructure. This single tool alone is an amazing monitoring tool. It not only monitors your Docker containers but the Docker host as well without any configuratio by just running the cAdvisor container on your Docker host. Be sure to check out the cAdvisor GitHub for more documentation on the API and different configuration options.

**[InfluxDB](influxdb.com)** - InfluxDB is a distributed time series database. cAdvisor only displays realtime information and doesn't store the metrics. We need to store the monitoring information which cAdvisor provides in order to display a time range other than realtime.

**[Grafana Metrics Dashboard](grafana.org)** - The Grafana Dashboard allows us to pull all the pieces together visually. This powerful Dashboard allows us to run queries against the InfluxDB and chart them accordingly in a very nice layout.


### 5.1 Preparing InfluxDB

In order to deploy the InfluxDB stack we need to clone the repository.

1. Create a directory called influxdb
2. Change directories to influxdb
3. Clone the InfluxDb project:

```
$ git clone https://github.com/vegasbrianc/docker-monitoring.git
```

Let's have a look at the InfluxDb project docker-compose file:

```
version: '2'

services:
 influxdbData:
  image: busybox
  volumes:
    - ./data/influxdb:/data

 influxdb:
  image: tutum/influxdb:0.9
  restart: always
  environment:
    - PRE_CREATE_DB=cadvisor
  ports:
    - "8083:8083"
    - "8086:8086"
  expose:
    - "8090"
    - "8099"
  volumes_from:
    - "influxdbData"

 cadvisor:
  image: google/cadvisor:v0.20.5
  links:
    - influxdb:influxsrv
  command: -storage_driver=influxdb -storage_driver_db=cadvisor -storage_driver_host=influxsrv:8086
  restart: always
  ports:
    - "8080:8080"
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:rw
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro

 grafana:
  image: grafana/grafana:2.6.0
  restart: always
  links:
    - influxdb:influxsrv
  ports:
    - "3000:3000"
  environment:
    - HTTP_USER=admin
    - HTTP_PASS=admin
    - INFLUXDB_HOST=influxsrv
    - INFLUXDB_PORT=8086
    - INFLUXDB_NAME=cadvisor
    - INFLUXDB_USER=root
    - INFLUXDB_PASS=root
```


### 5.2 Deploying InfluxDb
Now that we understand what the stack is doing let's deploy it to our Docker host. 

```
$ docker-compose up
```

### 5.2 Connecting to InfluxDB services
Congratulations, you now have deployed a InfluxDb stack with 3 different services. Before we get too far let's login to each service to see what they are doing.

cAdvisor - `http://<hostip>:8080`

InfluxDb - `http://<hostip>:8083`

Grafana - `http://<hostip>:3000`


# Next Steps
Now that you've built some images and pushed them to Docker, and learned the basics of Swarm mode, you can explore more of Docker by checking out [the documentation](https://docs.docker.com). And if you need any help, check out the [Docker Forums](https://forums.docker.com) or [StackOverflow](https://stackoverflow.com/tags/docker/).
