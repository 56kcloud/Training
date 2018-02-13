# Deploying an app to a Swarm

This portion of the tutorial will guide you through deplyoing a Docker Swarm, the creation and customization of a voting app. 

> **Tasks**:
>
>
> * [Task 1: Clone Voting App Repo](#Task_1)
> * [Task 2: Create Docker Swarm](#Task_2)
> * [Task 3: Customize the Voting App](#Task_3)

**Important.**
To complete this section, you will need to have Docker installed on your machine as mentioned in the [Setup](./setup.md) section. You'll also need to have git installed. There are many options for installing it. For instance, you can get it from [GitHub](https://help.github.com/articles/set-up-git/).

### <a name="Task_1"></a>Task 1: Clone Voting app
For this application we will use the [Docker Example Voting App](https://github.com/docker/example-voting-app). This app consists of five components:

* Python webapp which lets you vote between two options
* Redis queue which collects new votes
* .NET worker which consumes votes and stores them in…
* Postgres database backed by a Docker volume
* Node.js webapp which shows the results of the voting in real time

1. Clone the repository onto your machine and `cd` into the directory:

    ```
    $ git clone https://github.com/docker/example-voting-app.git
    
    $ cd example-voting-app
    ```


### <a name="Task_2"></a>Task 2: Initiate Docker Swarm
For this first stage, we will use existing images that are in Docker Store.

This app relies on [Docker Swarm mode](https://docs.docker.com/engine/swarm/). Swarm mode is the cluster management and orchestration features embedded in the Docker engine. You can easily deploy to a swarm using a file that declares your desired state for the app. Swarm allows you to run your containers on more than one machine. In this tutorial, you can run on just one machine, or you can use something like [Docker for AWS](https://beta.docker.com/) or [Docker for Azure](https://beta.docker.com/) to quickly create a multiple node machine. Alternately, you can use Docker Machine to create a number of local nodes on your development machine. See [the Swarm Mode lab](../../swarm-mode/beginner-tutorial/README.md#creating-the-nodes-and-swarm) for more information.

1. Query your IP Address
    
    ```
    $ ifconfig -a |grep -A 4 en0

    en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
    ether 3c:15:c2:d8:28:42
    inet6 fe80::1080:9acb:32c6:54a0%en0 prefixlen 64 secured scopeid 0x5
    inet 192.168.2.159 netmask 0xffffff00 broadcast 192.168.2.255
    nd6 options=201<PERFORMNUD,DAD>
    media: autoselect
    status: active
    ```
    *NOTE* For Winows users please use the `ipconfig`command to retieve your IP address

2. Create a Docker Swarm using the IP Address from step 1.

    ```
    $ docker swarm init --advertise-addr <IP Address from Step 1>

    Swarm initialized: current node (gshy63zz81kw3a7treejl2g4l) is now a manager.

    To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-1d764ibq33jqouhrpba7f9dchwzx38bfuw3ei5xmv0w87x00i1-at7fd6t18qj3ku0xu4xxgsh3i 192.168.2.159:2377

    To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
    ```

3. Next, locate the [Docker Compose](https://docs.docker.com/compose) file. You don't need Docker Compose installed, though if you are using Docker for Mac or Docker for Windows you already have it installed by default. The `docker stack` command utilizes the Docker Compose `YAML` file format. The file you need is in Docker Example Voting App at the root level. It's called docker-stack.yml. 

    Let's review what is inside the file:

    ```
    version: "3"
    services:

      redis:
        image: redis:alpine
        ports:
          - "6379"
        networks:
          - frontend
        deploy:
          replicas: 2
          update_config:
            parallelism: 2
            delay: 10s
          restart_policy:
            condition: on-failure
      db:
        image: postgres:9.4
        volumes:
          - db-data:/var/lib/postgresql/data
        networks:
          - backend
        deploy:
          placement:
            constraints: [node.role == manager]
      vote:
        image: dockersamples/examplevotingapp_vote:before
        ports:
          - 5000:80
        networks:
          - frontend
        depends_on:
          - redis
        deploy:
          replicas: 2
          update_config:
            parallelism: 2
          restart_policy:
            condition: on-failure
      result:
        image: dockersamples/examplevotingapp_result:before
        ports:
          - 5001:80
        networks:
          - backend
        depends_on:
          - db
        deploy:
          replicas: 1
          update_config:
            parallelism: 2
            delay: 10s
          restart_policy:
            condition: on-failure

      worker:
        image: dockersamples/examplevotingapp_worker
        networks:
          - frontend
          - backend
        deploy:
          mode: replicated
          replicas: 1
          labels: [APP=VOTING]
          restart_policy:
            condition: on-failure
            delay: 10s
            max_attempts: 3
            window: 120s
          placement:
            constraints: [node.role == manager]

      visualizer:
        image: dockersamples/visualizer
        ports:
          - "8080:8080"
        stop_grace_period: 1m30s
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        deploy:
          placement:
            constraints: [node.role == manager]

    networks:
      frontend:
      backend:

    volumes:
      db-data:
    ```

If you take a look at `docker-stack.yml`, you will see that the file defines

* vote container based on a Python image
* result container based on a Node.js image
* redis container based on a redis image, to temporarily store the data.
* .NET based worker app based on a .NET image
* Postgres container based on a postgres image

The Compose file also defines two networks, front-tier and back-tier. Each container is placed on one or two networks. Once on those networks, they can access other services on that network in code just by using the name of the service. Services can be on any number of networks. Services are isolated on their network. Services are only able to discover each other by name if they are on the same network. To learn more about networking check out the [Networking Lab](https://github.com/docker/labs/tree/master/networking).

Take a look at the file again. You'll see it starts with

```
version: "3"
```
It's important that you use version 3 of compose files, as `docker stack deploy` won't support use of earlier versions. You will see there's also a `services` key, under which there is a separate key for each of the services. Such as:
```
  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - 5000:80
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure
```

The `image` key there specifies which image you can use, in this case the image `dockersamples/examplevotingapp_vote:before`. If you're familiar with Compose, you may know that there's a `build` key, which builds based on a Dockerfile. However, `docker stack deploy` does not suppport `build`, so you need to use pre-built images.

Much like `docker run` you will see you can define `ports` and `networks`. There's also a `depends_on` key which allows you to specify that a service is only deployed after another service, in this case `vote` only deploys after `redis`.

The `deploy` key is new in version 3. It allows you to specify various properties of the deployment to the Swarm. In this case, you are specifying that you want two replicas, that is two containers are deployed on the Swarm. You can specify other properties, like when to restart, what [healthcheck](https://docs.docker.com/engine/reference/builder/#healthcheck) to use, placement constraints, resources.

4. Let's deploy our Vote Application to Docker Swarm:

    ```
    $ docker stack deploy --compose-file docker-stack.yml vote
    
    Creating network vote_frontend
    Creating network vote_backend
    Creating network vote_default
    Creating service vote_worker
    Creating service vote_visualizer
    Creating service vote_redis
    Creating service vote_db
    Creating service vote_vote
    Creating service vote_result
    ```

5. Verify your stack was deployed successfully:

    ```
    $ docker stack services vote
    
    ID            NAME         MODE        REPLICAS  IMAGE
    25wo6p7fltyn  vote_db      replicated  1/1       postgres:9.4
    2ot4sz0cgvw3  vote_worker  replicated  1/1       dockersamples/examplevotingapp_worker:latest
    9faz4wbvxpck  vote_redis   replicated  2/2       redis:alpine
    ocm8x2ijtt88  vote_vote    replicated  2/2       dockersamples/examplevotingapp_vote:before
    p1dcwi0fkcbb  vote_result  replicated  2/2       dockersamples/examplevotingapp_result:before
    ```

6. We can also check the services this which also provides the published ports:

    ```
    $ docker service ls
    
    ID                  NAME                MODE                REPLICAS            IMAGE                                          PORTS
    praz62mx8pis        vote_db             replicated          1/1                 postgres:9.4
    kn9m4pbgampm        vote_redis          replicated          1/1                 redis:alpine                                   *:30000->6379/tcp
    vboktn2bpb82        vote_result         replicated          1/1                 dockersamples/examplevotingapp_result:before   *:5001->80/tcp
    jqg43scwua0b        vote_visualizer     replicated          1/1                 dockersamples/visualizer:stable                *:8080->8080/tcp
    x794556ducqr        vote_vote           replicated          2/2                 dockersamples/examplevotingapp_vote:before     *:5000->80/tcp
    x85zjszmlxai        vote_worker         replicated          1/1                 dockersamples/examplevotingapp_worker:latest
    ```



#### Test the Vote App

1. Now that the app is running, you can go to `http://localhost:5000` to view the voting side of the app:

<img src="../images/vote.png" title="vote">

2. Select either `Dog` or `Cat` to vote. 

3. View the results: `http://localhost:5001`.

    **NOTE**: If you are running this tutorial in a cloud environment like AWS, Azure, Digital Ocean, or GCE you will not have direct access to localhost or 127.0.0.1 via a browser.  A work around for this is to leverage ssh port forwarding. Below is an example for Mac OS. Similarly this can be done for Windows and Putty users.

    ```
    $ ssh -L 5000:localhost:5000 <ssh-user>@<CLOUD_INSTANCE_IP_ADDRESS>
    ```

### <a name="Task_3"></a>Task 3:Customize the Voting App
In this step, you will customize the app and redeploy it. We've supplied the same images but with the votes changed from Cats and Dogs to Java and .NET using the `after` tag.

#### Change the images deployed

Go back to `docker-stack.yml`

1. Change the `vote` and `result` images to use the `after` tag, so they look like this:

    ```
      vote:
        image: dockersamples/examplevotingapp_vote:after
        ports:
          - 5000:80
        networks:
          - frontend
        depends_on:
          - redis
        deploy:
          replicas: 2
          update_config:
            parallelism: 2
          restart_policy:
            condition: on-failure
      result:
        image: dockersamples/examplevotingapp_result:after
        ports:
          - 5001:80
        networks:
          - backend
        depends_on:
          - db
        deploy:
          replicas: 2
          update_config:
            parallelism: 2
            delay: 10s
          restart_policy:
            condition: on-failure

    ```


#### Redeploy
Next, we want to redeploy our Vote Application stack with the new changes. The `docker stack deploy` will review the `docker-stack.yml`file for changes and update all the services and connections accordingly.

2. Redeploy Vote Stack: 

    ```
    $ docker stack deploy --compose-file docker-stack.yml vote

    Updating service vote_db (id: praz62mx8pisq07tziygllvb5)
    Updating service vote_vote (id: x794556ducqre2op47nehov32)
    Updating service vote_result (id: vboktn2bpb822gnfpc3t73qiw)
    Updating service vote_worker (id: x85zjszmlxaihkub8xvmtuxx3)
    Updating service vote_visualizer (id: jqg43scwua0bhxpcmyghuur74)
    Updating service vote_redis (id: kn9m4pbgampm6ewncyycqx94m)
    ```

#### Another test run

Now place another vote `http://localhost:5000` and view the results `http://localhost:5001`

#### Remove the stack

3. Remove the stack from the swarm.

    ```
    $ docker stack rm vote
    ```

### Next steps Docker Secrets
For the next step in the tutorial, head over to [Docker Secrets](secrets.md)
