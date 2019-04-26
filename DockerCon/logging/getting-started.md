# Our First Logs

Let's take a look at Docker Logging

> **Tasks**:
>
>
> * [Task 1: Log our first containers](#Task_1)
> * [Task 2: Understanding the Docker Logs command](#Task_2)
> * [Task 3: docker-compose logs](#Task_3)
> * [Recap topics covered in this section](#Recap)

## <a name="Task_1"></a>Task 1: Start a Traefik Proxy to log

Now that Docker is setup, it's time to get our hands dirty. In this section, you are going to run a reverse proxy called [Traefik](https://traefik.io/) container (a high-performance webserver, load-balancer, and proxy) on your system and get hands-on with the `docker logs` command.

1. To get started, create a new file named `traefik.toml`and add the below configuration to the newly created file.

    ```
    ################################################################
    # API and dashboard configuration
    ################################################################
    123[api]
    ################################################################
    # Docker configuration backend
    ################################################################
    [docker]
    domain = "docker.local"
    watch = true
    ################################################################
    # Enable Access Logs
    ################################################################
    [accessLog]
    ```

2. Start the `Traefik` proxy. Ensure the `traefik.toml` is in your current working directory.

  ```
  docker run -d -p 8080:8080 -p 80:80 --name traefik -v $PWD/traefik.toml:/etc/traefik/traefik.toml -v /var/run/docker.sock:/var/run/docker.sock traefik
  ```


3. Ensure the `Traefik` container is running by running the `ls` command with `-l` showing last container

    ```
     docker container ps -l
   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS       NAMES
   0b2062765e41        traefik             "/traefik"          8 minutes ago       Exited (1) 8 minutes ago                  Traefik

    ```

    Uh oh, what happend?
    We can actually use the `docker logs` command on stopped containers to troubleshoot. Great, let's do it.

4. Check the logs of the `Traefik` container to see why the container didn't start

    ```
     docker logs traefik
    2019/04/25 15:11:51 Error reading TOML config file /etc/traefik/traefik.toml : Near line 3 (last key parsed ''): bare keys cannot         contain '['
    ```

5. OK, remove the `Traefik` container

    ```
     docker container rm -f traefik
    ```

    > This is the forceful way to remove it. With great power comes great responsability. You are warned!

6. Fix the `traefik.toml` configuratiion file line 4 removing `123` in front of the `[API]` block
    ```
    ################################################################
    # API and dashboard configuration
    ################################################################
    [api]
    ################################################################
    # Docker configuration backend
    ################################################################
    [docker]
    domain = "docker.local"
    watch = true
    ################################################################
    # Enable Access Logs
    ################################################################
    [accessLog]
    ``` 

7. Start `Traefik` with the fixed configuration file. Ensure the `traefik.toml` is in your current working directory.

    ```
      docker run -d -p 8080:8080 -p 80:80 --name traefik -v $PWD/traefik.toml:/etc/traefik/traefik.toml -v /var/run/docker.sock:/var/run/docker.sock traefik
    ```

8. Ensure the `Traefik` container is running

    ```
     docker container ps -l
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                         NAMES
    e72a26a2b752        traefik             "/traefik"          5 seconds ago       Up 3 seconds        0.0.0.0:80->80/tcp,0.0.0.0:8080->8080/tcp   traefik
    ```

9. Test the `Traefik` container with `curl` or open a browser tab and navigate to: `https://0.0.0.0` (PWD just click the link provided above the terminal)

    ```
     curl 0.0.0.0:8080
    ```

    Go ahead and send a few curl/refresh request to the `Traefik` container.

10. Check the logs

    ```
     docker container logs traefik
    ```

    > What do we see different? We should now see the each curl/refresh we sent to the `Traefik` container


We should see a 404 error about no backends configured.


Now, we will connect a `whoami` container to the `Traefik` proxy. This `whoami` container will register itself automatically with the proxy. The `Traefik` proxy routes traffic from `0.0.0.0`from the `Traefik` proxy to our new `whoami` application.

10. Start the `whoami` container

    `docker run -d --name whoami emilevauge/whoami`

    > `Traefik` watches the Docker daemon for any new containers that start. When a new container starts it automatically registers it with `Traefik`

11. Let's check the logs to see if it the `whoami` container registered with the proxy

    `  docker container logs traefik`

    We should see the whoami ID register with the proxy
    ```
    172.17.0.1 - - [25/Apr/2019:15:37:33 +0000] "GET / HTTP/1.1" 200 326 "-" "curl/7.47.0" 5 "Host-test-docker-local-0" "http://172.17.0.5:80" 1ms
    172.17.0.1 - - [25/Apr/2019:15:37:36 +0000] "GET / HTTP/1.1" 200 326 "-" "curl/7.47.0" 6 "Host-test-docker-local-0" "http://172.17.0.5:80" 1ms
    172.17.0.1 - - [25/Apr/2019:15:37:37 +0000] "GET / HTTP/1.1" 200 326 "-" "curl/7.47.0" 7 "Host-test-docker-local-0" "http://172.17.0.5:80" 0ms
    ```

12. `curl` the whoami container using the Virtual Hostname `test.docker.local`configured in `Traefik`

    ```
     curl --header 'Host: test.docker.local' 'http://localhost:80/'

    Response
    Hostname: 299f3c36eb18
    IP: 127.0.0.1
    IP: 172.17.0.5
    GET / HTTP/1.1
    Host: test.docker.local
    User-Agent: curl/7.47.0
    Accept: */*
    Accept-Encoding: gzip
    X-Forwarded-For: 172.17.0.1
    X-Forwarded-Host: test.docker.local
    X-Forwarded-Port: 80
    X-Forwarded-Proto: http
    X-Forwarded-Server: 10744bcc8a7d
    X-Real-Ip: 172.17.0.1
    ```
12. Finally, run the `docker container logs` command on the proxy to ensure everything is now working as expected

    `docker container logs traefik`

    > We now see the hostname which is queried and a `HTTP 200` success code
    
    ```
      172.17.0.1 - - [25/Apr/2019:15:37:33 +0000] "GET / HTTP/1.1" 200 326 "-" "curl/7.47.0" 5 "Host-test-docker-local-0" "http://172.17.0.5:80" 1ms
    172.17.0.1 - - [25/Apr/2019:15:37:36 +0000] "GET / HTTP/1.1" 200 326 "-" "curl/7.47.0" 6 "Host-test-docker-local-0" "http://172.17.0.5:80" 1ms
    172.17.0.1 - - [25/Apr/2019:15:37:37 +0000] "GET / HTTP/1.1" 200 326 "-" "curl/7.47.0" 7 "Host-test-docker-local-0" "http://172.17.0.5:80" 0ms
    ```


### <a name="Task_2"></a>Task 2: Understanding the Docker Logs Command

The `docker container logs` command is a powerful command and is used for troubleshooting, analyzing, and general information gathering. The command is useful to Developers to debug new applications as well as Operations for information gathering.

1. Great! Let's now take a look at the `docker container logs` help to better understand how we can best use the command

    ```
     docker container logs --help

    Usage:  docker logs [OPTIONS] CONTAINER

    Fetch the logs of a container

    Options:
        --details        Show extra details provided to logs
    -f, --follow         Follow log output
        --since string   Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
        --tail string    Number of lines to show from the end of the logs (default "all")
    -t, --timestamps     Show timestamps
        --until string   Show logs before a timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
    ```

2. Add timestamps to our logging output. This will help with narrowing down when events occured if no timestamp is created in the log message.

    ```
     docker container logs -t traefik
    ```

3. Tail the last `n` number of lines in the log file

    This is extremely helpful when logs become very big. If you were to run a `docker logs` command on a large log it could over run your terminal winder


    ```
     docker container logs --tail 5 traefik
    ```

4. Follow the log for real-time updates.

    ```
     docker container logs -t -f traefik
    ```
    
    Curl or refresh the `whoami` container a couple times to see the log update.
    
    ``` 
    curl --header 'Host: test.docker.local' 'http://localhost:80/'
    ``` 


5. Restart the `Traefik` container

     ```
     docker container restart traefik
    ```

6. Check the logs again. What do you notice?

    ```
     docker container logs traefik
    ```

    > The logs still persist inside the container from our previous tests.

7. Stop and remove the `Traefik` container

    ```
     docker container rm -f traefik
    ```

8. Start `Traefik` again

    ```
     docker run -d -p 8080:8080 -p 80:80 --name traefik -v $PWD/traefik.toml:/etc/traefik/traefik.toml -v /var/run/docker.sock:/var/run/docker.sock traefik
    ```

9. Check the logs. What do you notice?

    ```
     docker container logs traefik
    ```

    > This time we removed the container and started a new container. It is important to notice now the logs didn't persist. This is why   it is important we persist logs outside of the containers.

10. Cleanup running containers

    ` docker container rm -f whoami traefik`


### <a name="Task_3"></a>Task 3: docker-compose and logging

We have now seen how logging works in a single container. Now, we want to see what logs look like when multiple containers are running in a compose file. In this example we will use the docker voting application. This stack contains 5 different containers running with one docker-compose file.

1. Clone the Voting App Repo

    ```
     git clone https://github.com/dockersamples/example-voting-app.git
    ```

2. Start the Voting App with docker-compose.

    ```
     cd example-voting-app

     docker-compose up -d
    ```

3. Once the voting application stack has started. Check the logs of the voting app stack.


    ```
     docker-compose logs
    ```

    What we notice is that Docker color codes the log based on container names. Since we have 5 different containers this makes it easier when viewing from a terminal window.

4. Expanding the command to capture certain containers

    ```
     docker-compose logs redis
    ```

5. Open a browser tab `http://0.0.0.0:5000` and place a few votes and watch the logs. For those using PWD, click the link that appeared at the top the dashboard.

    > Since no timestamp is in the log it is difficult to see if new votes arrived or not.

6. Combing everything we learned

    ```
     docker-compose logs --follow -t redis
    ```

    > Again place some more votes on `http://0.0.0.0:5000` and see the difference in the logs

### Cleanup

1. Time to remove the running containers

    ```
     docker-compose stop
    ```


## <a name="Terminology"></a>Recap

What did we learn in this section?

* Running `docker logs` on stopped containers
* Troubleshooting containers
* The `docker logs`command is actually quite powerful and can be combined with other tools like the Linux `grep` command or others
* Logs don't persist in containers once the container is removed
* `docker-compose logs` works similarly to `docker logs` but displays all containers in the compose stack

## Next Steps, Docker Swarm & Logs
For the next step in the workshop, head over to [Docker Swarm & Logging](./log-drivers.md)
