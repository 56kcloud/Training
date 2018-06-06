# Our First Logs

Let's take a look at Docker Logging

> **Tasks**:
>
>
> * [Task 1: Run our First Container](#Task_1)
> * [Task 2: Understanding the Docker Logs command](#Task_2)
> * [Task 3: docker-compose logs](#Task_3)
> * [Recap topics covered in this section](#Recap)

## <a name="Task_1"></a>Task 1: Running your first container

Now that Docker is setup, it's time to get our hands dirty. In this section, you are going to run a variant of NGINX called [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/) container (a high-performance webserver, load-balancer, and proxy) on your system and get hands-on with the `docker logs` command.

1. To get started, let's run the following in our terminal:

    ```
    $ docker run -d --name nginx -p 8080:80 jwilder/nginx-proxy:alpine
    Unable to find image 'jwilder/nginx-proxy:alpine' locally
    alpine: Pulling from jwilder/nginx-proxy
    ff3a5c916c92: Already exists
    b430473be128: Pull complete
    7d4e05a01906: Pull complete
    8aeac9a3205f: Pull complete
    4051da9b64e1: Pull complete
    6e3d3f4d490b: Pull complete
    c12a8c9833a1: Pull complete
    e5211b7bcfb8: Pull complete
    84f8322407bb: Pull complete
    8072554e5444: Pull complete
    2872c76767cf: Pull complete
    Digest: sha256:6181afd7ce4a0291bf73b1787be33928213203401ccbeee2cd720db5d700636b
    Status: Downloaded newer image for jwilder/nginx-proxy:alpine
    673f5eed33e6ebea397bb162567a66923f3772c6e409f0de4614467d0f157f93
    
    ```

2. Ensure the `NGINX` container is running

    ```
    $ docker ps
    CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                  NAMES
    ```

    Uh oh, what happend?
    We can actually use the `docker logs` command on stopped containers.

3. Check the logs of the `NGINX` container to see why it didn't start

    ```
    $ docker logs nginx
    ERROR: you need to share your Docker host socket with a volume at /tmp/docker.sock
    Typically you should run your jwilder/nginx-proxy with: `-v /var/run/docker.sock:/tmp/docker.sock:ro`
    See the documentation at http://git.io/vZaGJ
    WARNING: /etc/nginx/dhparam/dhparam.pem was not found. A pre-generated dhparam.pem will be used for now while a new one
    is being generated in the background.  Once the new dhparam.pem is in place, nginx will be reloaded.
    ```

4. OK, stop and remove the `NGINX` container

    ```
    $ docker rm -f nginx
    ```

    > This is the forceful way to remove it. Not recommend in production

5. Start `NGINX` with the suggestions from the log file

    ```
    $ docker run  -d -p 8080:80 -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --name nginx \
    jwilder/nginx-proxy:alpine
    ```

6. Ensure the `NGINX` container is running

    ```
    $ docker ps
    CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                  NAMES
    960ab9aed7af        jwilder/nginx-proxy:alpine   "/app/docker-entrypo…"   3 seconds ago       Up 3 seconds        0.0.0.0:8080->80/tcp   nginx
    ```

7. Test the `NGINX` container with `curl` or open a browser tab and navigate to: `https://0.0.0.0:8080` (PWD just click the link provided above the terminal)

    ```
    $ curl 0.0.0.0:8080
    ```

    Go ahead and send a few curl/refresh request to the `NGINX` container.

8. Check the logs

    ```
    $ docker logs nginx
    ```

    > What do we see different? We should now see the each curl/refresh we sent to the `NGINX` container

9. Restart the `NGINX` container

     ```
    $ docker restart nginx
    ```

10. Check the logs again. What do you notice?

    ```
    $ docker logs nginx
    ```

    > The logs still persist inside the container from our previous tests.

11. Stop and remove the NGINX container

    ```
    $ docker rm -f nginx
    ```

12. Start `NGINX` again

    ```
    $ docker run  -d -p 8080:80 -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --name nginx \
    jwilder/nginx-proxy:alpine
    ```

13. Check the logs. What do you notice?

    ```
    $ docker logs nginx
    ```

    > This time we removed the container and started a new container. It is important to notice now the logs didn't persist. This is why it is important we persist logs outside of the containers.

### <a name="Task_2"></a>Task 2: Understanding the Docker Logs Command

The `docker logs` command is a powerful command and is used for troubleshooting, analyzing, and general information gathering. The command is useful to Developers to debug new applications as well as Operations for information gathering.

1. Great! Let's now take a look at the `docker logs` help to better understand how we can best use the command

    ```
    $ docker logs --help

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
    $ docker logs -t nginx
    ```

3. Tail the last `n` number of lines in the log file

    This is extremly helpful when logs become very big. If you were to run a `docker logs` command on a large log it could over run your terminal winder


    ```
    $ docker logs --tail 5 nginx
    ```

4. Follow the log for real-time updates. 
    
    ```
    $ docker logs -t -f nginx
    ```

    Curl or refresh the URL 0.0.0.0:8080 a couple times to see the log update

### <a name="Task_3"></a>Task 3: docker-compose and logging

We have now seen how logging works in a single container. Now, we want to see what logs look like when multiple containers are running in a compose file. In this example we will use the docker voting application. This stack contains 5 different containers running with one docker-compose file.

1. Clone the Voting App Repo

    ```
    $ git clone https://github.com/dockersamples/example-voting-app.git
    ```

2. Start the Voting App with docker-compose.

    ```
    $ cd example-voting-app

    $ docker-compose up -d
    ```

3. Once the voting application stack has started. Check the logs of the voting app stack.


    ```
    $ docker-compose logs
    ```

    What we notice is that Docker color codes the log based on container names. Since we have 5 different containers this makes it easier when viewing from a terminal window.

4. Expanding the command to capture certain containers

    ```
    $ docker-compose logs |grep vote_1
    ```

5. Open a browser tab `http://0.0.0.0:5000` and place a few votes and watch the logs. 

    > Since no timestamp is in the log it is difficult to see if new votes arrived or not.

6. Combing everything we learned

    ```
    $ docker-compose logs --follow -t |grep vote_1
    ```

    > Again place some more votes on `http://0.0.0.0:5000` and see the difference in the logs

## <a name="Terminology"></a>Recap

What did we learn in this section?

* Running `docker logs` on stopped containers
* Logs don't persist in containers once the container is removed
* The `docker logs`command is actually quite powerful and can be combined with other tools like the Linux `grep` command or others
* `docker-compose logs` works similiarly to `docker logs` but displays all containers in the compose stack

## Next Steps, Docker Swarm & Logs
For the next step in the workshop, head over to [Docker Services & Swarm Logging](./swarm-logs.md)
