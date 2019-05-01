# Docker Stats, Top, and other built-in Monitoring Tools

Time to dive into the world of monitoring. First, we will explore the various built-in tools offered by Docker

> **Tasks**:
>
>
> * [Task 1: Docker Stats](#Task_1)
> * [Task 2: Docker System info, events, df](#Task_2)
> * [Task 3: Docker Top](#Task_3)
> * [Task 4: Recap](#Task_4)

## <a name="Task_1"></a>Task 1: Docker Stats

First, we need to start some containers to monitor. Return back to the voting application directory we used in the logging section and start the Vote App stack. `docker stats` uses the same concept as most monitoring tools as it is querying the docker daemon directly for information. We can query ID's, Names, CPU, Memory, Network, storage, and processes.

1. To get started, let's start the compose demo application stack again:

    ```
    cd docker-compose-demo

    docker-compose up -d
    ```

2. Now, let's take a look at the `stats` of the individual containers running in the Vote App stack 

    ```
    docker stats

    CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
    d4bd451f0b68        demo3_worker_1      0.98%               21.77MiB / 1.952GiB   1.09%               466kB / 717kB       43MB / 0B           17
    1aaa67a5a5a8        redis               0.46%               1.344MiB / 1.952GiB   0.07%               330kB / 153kB       2MB / 0B            4
    d6d556507c0f        demo3_vote_1        0.40%               31.23MiB / 1.952GiB   1.56%               3.34kB / 0B         14.3MB / 0B         3
    511eb5d3a5f4        db                  0.33%               8.641MiB / 1.952GiB   0.43%               432kB / 346kB       27.4MB / 119kB      8
    7c726e569b7b        demo3_result_1      0.07%               38.05MiB / 1.952GiB   1.90%               154kB / 45.6kB      35.3MB / 12.3kB     20
    ```

    > Notice the screen refreshes automatically. We also notice that no limits have been set for Memory. Shame shame!

3. We can also narrow the `stats` command to just a selected container

    ``` 
    docker stats redis
    CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
    1aaa67a5a5a8        redis               0.46%               1.344MiB / 1.952GiB   0.07%               657kB / 302kB       2MB / 0B            4
    ``` 

### <a name="Task_2"></a>Task 2: Docker System info and df

Docker has some great built-in tools. We just have to know where to find them.

1. The `docker system info` command provides an overview of the docker host indicating total available CPU, memory, storage, etc

    `docker system info`

    > Scroll through the output to see all the available information


2. One of the most important commands in the Linux world to check storage is `df` (Display free disk space). Docker has tailored the `df` command for containers. Now we see storage information about Containers, Images, and Volumes.

    ```
    docker system df
    TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
    Images              51                  14                  6.868GB             6.349GB (92%)
    Containers          21                  5                   679.2kB             378.9kB (55%)
    Local Volumes       19                  4                   116.4MB             79.21MB (68%)
    Build Cache                                                 0B                  0B
    ```

### <a name="Task_3"></a>Task 3: Docker Top

Background containers are how you'll run most applications. Here's a simple example using MySQL.

1. You can check the processes which run in your containers : `docker container top`

    Let's look at the running processes inside the container.

    ```
    docker container top redis
    PID                 USER                TIME                COMMAND
    8480                rpc                 0:00                redis-server
    ```

    You should see the redis demon (`redis-server`) is running. Note that the PID shown here is the PID for this process on your docker host. To see the same `redis-server` process running as the main process of the container (PID 1) try:

    ```
	docker container exec redis ps -ef
	PID   USER     TIME   COMMAND
    1 redis      0:00 redis-server
   12 root       0:00 ps -ef
	```

## Clean up
Remove the compose demo stack
   ```
   docker-compose rm -fs
   ```
## <a name="Terminology"></a>Recap

What did we learn in this section?

* Real-time CLI monitoring with `docker stats`
* `docker system info`provides Docker Host information
* Display free disk space using `docker system df`
* `docker-compose top` displays processes running inside the containers.

## Next Steps, Google cAdvisor (Container Advisor)
For the next step in the tutorial, head over to [Google cAdvisor](./cadvisor.md)