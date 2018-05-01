# Our First Containers

The wait is finally over. It's time to roll up our sleeves and start our first container. Get Ready.

> **Tasks**:
>
>
> * [Task 1: Run our First Container](#Task_1)
> * [Task 2: Run an Interactive Container](#Task_2)
> * [Task 3: Run a background MySQL container](#Task_3)
> * [Terminology Covered in this section](#Terminology)

## <a name="Task_1"></a>Task 1: Running your first container

Now that Docker is setup, it's time to get our hands dirty. In this section, you are going to run an [Alpine Linux](http://www.alpinelinux.org/) container (a lightweight linux distribution) on your system and get hands-on with the `docker run` command.

1. To get started, let's run the following in our terminal:

    ```
    $ docker image pull alpine
    Unable to find image 'alpine:latest' locally
    latest: Pulling from library/alpine
    88286f41530e: Pull complete
    Digest: sha256:f006ecbb824d87947d0b51ab8488634bf69fe4094959d935c0c103f4820a417d
    Status: Downloaded newer image for alpine:latest
    ```

> **Note:** Depending on how you've installed docker on your system, you might see a `permission denied` error after running the above command. Try the commands from the Getting Started tutorial to [verify your installation](https://docs.docker.com/engine/getstarted/step_one/#/step-3-verify-your-installation). If you're on Linux, you may need to prefix your `docker` commands with `sudo`. Alternatively you can [create a docker group](https://docs.docker.com/engine/installation/linux/ubuntulinux/#/create-a-docker-group) to get rid of this issue.

2. The `pull` command fetches the alpine **image** from the **Docker registry** and saves it in our system. You can use the `docker images` command to see a list of all images on your system.

    ```
    $ docker images

    REPOSITORY              TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    alpine                  latest              3fd9065eaf02        2 weeks ago         4.15MB
    hello-world             latest              f2a91732366c        2 months ago        1.85kB
    ```

### Run a single-task Alpine Linux Container

1. Great! Let's now run a Docker **container** based on this image. To do that you are going to use the `docker container run` command.

    ```
    $ docker container run alpine hostname

    888e89a3b36

    ```

What happened? Behind the scenes, a lot of stuff happened. When you call `container run`,
1. The Docker client contacts the Docker daemon
2. The Docker daemon checks local store if the image (alpine in this case) is available locally, and if not, dowloads it from Docker Store. (Since we have issued `docker pull alpine` before, the download step is not necessary)
3. The Docker daemon creates the container and then runs a command in that container.
4. The Docker daemon streams the output of the command to the Docker client

When you run `docker container run alpine`, you provided a command (`hostname`), so Docker started the command specified and returned the hostname (`888e89a3b36`) of the container.


2. Docker keeps a container running as long as the process it started inside the container is still running. In this case, the hostname process completes when the output is written, so the container exits. The Docker platform doesn't delete resources by default, so the container still exists in the Exited state.

    List all containers:

    ```
    $ docker container ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS            PORTS               NAMES
    888e89a3b36b        alpine              "hostname"          50 seconds ago      Exited (0) 49 seconds ago             awesome_elion
    ```

    Notice that your Alpine Linux container is in the `Exited` state.

    Note: The container ID is the hostname that the container displayed. In the example above it's 888e89a3b36b

Containers which do one task and then exit can be very useful. You could build a Docker image that executes a script to configure something. Anyone can execute that task just by running the container - they don't need the actual scripts or configuration information.


3. Let's try something more exciting.

    ```
    $ docker container run alpine echo "hello from alpine"
    hello from alpine
    ```

    OK, that's some actual output. In this case, the Docker client ran the `echo` command inside our alpine container and then exited it. If you've noticed, all of that happened pretty quickly. Compare the same process to booting up a virtual machine, running a command and then killing it. Now you know why they say containers are fast!

4. Try another command:

    ```
    $ docker container run alpine /bin/sh
    ```

    Wait, nothing happened! Is that a bug? Well, no. These interactive shells will exit after running any scripted commands, unless they are run in an interactive terminal - so for this example to not exit, you need to run:

    ```
    $docker container run -it alpine /bin/sh
    ```

You are now inside the container shell and you can try out a few commands like `ls -l`, `uname -a` and others. Exit out of the container by giving the `exit` command.


5. Ok, now it's time to see the `docker contianer ps` or the shortcut `docker ps` command. The `docker ps` command shows you all containers that are currently running.

    ```
    $ docker container ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    ```

6. Since no containers are running, you see a blank line. Let's try a more useful variant: `docker container ps -a`

    ```
    $ docker container ps -a
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
    36171a5da744        alpine              "/bin/sh"                5 minutes ago       Exited (0) 2 minutes ago                        fervent_newton
    a6a9d46d0b2f        alpine              "echo 'hello from alp"   6 minutes ago       Exited (0) 6 minutes ago                        lonely_kilby
    ff0a5c3750b9        alpine              "ls -l"                  8 minutes ago       Exited (0) 8 minutes ago                        elated_ramanujan
    c317d0a9e3d2        hello-world         "/hello"                 34 seconds ago      Exited (0) 12 minutes ago                       stupefied_mcclintock
    ```

7. What you see above is a list of all containers that you ran. Notice that the `STATUS` column shows that these containers exited a few minutes ago. You're probably wondering if there is a way to run more than just one command in a container. Let's try that now:

    ```
    $ docker container run -it alpine /bin/sh
    / # ls
    bin      dev      etc      home     lib      linuxrc  media    mnt      proc     root     run      sbin     sys      tmp      usr      var
    / # uname -a
    Linux 97916e8cb5dc 4.4.27-moby #1 SMP Wed Oct 26 14:01:48 UTC 2016 x86_64 Linux
    ```
    
    Type `exit` or `CTRL-D` to exit the interactive container. Once we exit the container the container will also exit and stop.

    Running the `run` command with the `-it` flags attaches us to an interactive tty in the container. Now you can run as many commands in the container as you want. Take some time to run your favorite commands.

That concludes a whirlwind tour of the `docker run` command which would most likely be the command you'll use most often. It makes sense to spend some time getting comfortable with it. To find out more about `run`, use `docker container run --help` to see a list of all flags it supports. As you proceed further, we'll see a few more variants of `docker container run`.


### <a name="Task_2"></a>Task 2: Run an interactive Ubuntu container

You can run a container based on a different version of Linux than what is running on your Docker host.

In the next example, we are going to run an Ubuntu Linux container.

1. Run a Docker container and access its shell.

    In this case we're giving the `docker container run` command three parameters:

    * `--interactive` says you want an interactive session
    * `--tty` allocates a psuedo-tty
    * `--rm` tells Docker to go ahead and remove the container when it's done executing

    The first two parameters allow you to interact with the Docker container.

    We're also telling the container to run `bash` as its main process (PID 1).

    ```
    $ docker container run --interactive --tty --rm ubuntu bash
    ```

    When the container starts you'll drop into the bash shell with the default prompt `root@<container id>:/#`. Docker has attached to the shell in the container, relaying input and output between your local session and the shell session in the container.

2. Run some commands in the container:

    - `ls /` - lists the contents of the root directory
    - `ps aux` - shows all running processes in the container.
    - `cat /etc/issue` - shows which Linux distro the container is running, in this case Ubuntu 16.04.3 LTS

3. Type `exit` to leave the shell session. This will terminate the `bash` process, causing your container to exit.

    > **Note:** As we used the `--rm` flag when we started the container, Docker removed that container when it stopped. This means if you run another `docker container ls --all` you won't see the Ubuntu container.

4. For fun, let's check the version of our host VM

    ```
    $ cat /etc/issue

    Ubuntu 16.04.3 LTS \n \l
    ```

    Notice that our host VM is Ubuntu, yet we were able to run an Ubuntu container. As previously mentioned, the distribution of Linux in the container does not need to match the distribution of Linux running on the Docker host.

Interactive containers are useful when you are putting together your own image. You can run a container and verify all the steps you need to deploy your app, and capture them in a Dockerfile.

> **Note:** You *can* [commit](https://docs.docker.com/engine/reference/commandline/commit/) a container to make an image from it - but you should avoid that wherever possible. It's much better to use a repeatable [Dockerfile](https://docs.docker.com/engine/reference/builder/) to build your image. You'll see that shortly.

5. To exit the shell of the Ubunutu container:

	```
	$ exit
	```

We can exit the TTY of the container with by typing `exit` or `CTRL-D`

### <a name="Task_3"></a>Task 3: Run a background MySQL container

Background containers are how you'll run most applications. Here's a simple example using MySQL.

1. Let's run MySQL in the background container using the `--detach` flag. We'll also use the `--name` flag to name the running container `mydb`.

    We'll also use an environment variable (`--env`) to set the root password (NOTE: This should never be done in production):

    ```
    $ docker container run \
    --detach \
    --name mydb \
    --env MYSQL_ROOT_PASSWORD=my-secret-pw \
    mysql:latest

    Unable to find image 'mysql:latest' locallylatest: Pulling from library/mysql
    aa18ad1a0d33: Pull complete
    fdb8d83dece3: Pull complete
    <Snip>
     315e21657aa4: Pull complete
    Digest: sha256:0dc3dacb751ef46a6647234abdec2d47400f0dfbe77ab490b02bffdae57846ed
    Status: Downloaded newer image for mysql:latest
    41d6157c9f7d1529a6c922acb8167ca66f167119df0fe3d86964db6c0d7ba4e0
    ```

    Once again, the image we requested was not available locally, so Docker pulled it from Docker Hub.

    As long as the MySQL process is running, Docker will keep the container running in the background.

2. List running containers

    ```
    $ docker container ls
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS            NAMES
    3f4e8da0caf7        mysql:latest        "docker-entrypoint..."   52 seconds ago      Up 51 seconds       3306/tcp         mydb
    ```

    Notice your container is running

3. You can check what's happening in your containers by using a couple of built-in Docker commands: `docker container logs` and `docker container top`

    ```
    $ docker container logs mydb
    <output truncated>
    2017-09-29T16:02:58.605004Z 0 [Note] Executing 'SELECT * FROM INFORMATION_SCHEMA.TABLES;' to get a list of tables using the deprecated partition engine. You may use the startup option '--disable-partition-engine-check' to skip this check.
    2017-09-29T16:02:58.605026Z 0 [Note] Beginning of list of non-natively partitioned tables
    2017-09-29T16:02:58.616575Z 0 [Note] End of list of non-natively partitioned tables
    ```

    This shows the logs from your Docker container.

    Let's look at the running processes inside the container.

    ```
    $ docker container top mydb
    PID                 USER                TIME                COMMAND
    6930                999                 0:00                mysqld
    ```

    You should see the MySQL demon (`mysqld`) is running. Note that the PID shown here is the PID for this process on your docker host. To see the same `mysqld` process running as the main process of the container (PID 1) try:

    ```
	$ docker container exec mydb ps -ef
	UID         PID   PPID  C STIME TTY          TIME CMD
	mysql         1      0  0 21:00 ?        00:00:01 mysqld
	root        207      0  0 21:39 ?        00:00:00 ps -ef
	```

    Although MySQL is running, it is isolated within the container because no network ports have been published to the host. Network traffic cannot reach containers from the host unless ports are explicitly published.

4. List the MySQL version using `docker container exec`.

   `docker container exec` allows you to run a command inside a container. In this example, we'll use `docker container exec` to run the command-line equivalent of `mysql --user=root --password=$MYSQL_ROOT_PASSWORD --version` inside our MySQL container.

    ```
    $ docker container exec -it mydb \
    mysql --user=root --password=$MYSQL_ROOT_PASSWORD --version

    mysql: [Warning] Using a password on the command line interface can be insecure.
    mysql  Ver 14.14 Distrib 5.7.19, for Linux (x86_64) using  EditLine wrapper
    ```

    The output above shows the MySQL version number, as well as a handy warning.

5. You can also use `docker container exec` to connect to a new shell process inside an already-running container. Executing the command below will give you an interactive shell (`sh`) in your MySQL container.  

    ```
    $ docker exec -it mydb sh
    #
    ```

    Notice that your shell prompt has changed. This is because your shell is now connected to the `sh` process running inside of your container.

6. Let's check the version number by running the same command we passed to the container in the previous step.

    ```
    # mysql --user=root --password=$MYSQL_ROOT_PASSWORD --version

    mysql: [Warning] Using a password on the command line interface can be insecure.
    mysql  Ver 14.14 Distrib 5.7.19, for Linux (x86_64) using  EditLine wrapper
    ```

    Notice the output is the same as before.

7. Type `exit` to leave the interactive shell session.

    Your container will still be running. This is because the `docker container exec` command started a new `sh` process. When you typed `exit`, you exited the `sh` process and left the `mysqld` process still running.

Let's clean up for the next lab.

8. Stop the MySQL container

    ````
    $ docker container stop mydb
    ```

9. Remove the MySQL container

    ```
    $ docker container rm mydb
    ```

10. Delete the MySQL image

    ```
    $ docker image rm mysql
    ```



### Terminology
In the last section, you saw a lot of Docker-specific jargon which might be confusing to some. So before you go further, let's clarify some terminology that is used frequently in the Docker ecosystem.

- *Images* - The file system and configuration of our application which are used to create containers. To find out more about a Docker image, run `docker image inspect alpine`. In the demo above, you used the `docker image pull` command to download the **alpine** image. When you executed the command `docker container run hello-world`, it also did a `docker image pull` behind the scenes to download the **hello-world** image.
- *Containers* - Running instances of Docker images &mdash; containers run the actual applications. A container includes an application and all of its dependencies. It shares the kernel with other containers, and runs as an isolated process in user space on the host OS. You created a container using `docker container run` which you did using the alpine image that you downloaded. A list of running containers can be seen using the `docker container ps` command.
- *Docker daemon* - The background service running on the host that manages building, running and distributing Docker containers.
- *Docker client* - The command line tool that allows the user to interact with the Docker daemon.
- *Docker Store* - A [registry](https://store.docker.com/) of Docker images, where you can find trusted and enterprise ready containers, plugins, and Docker editions. You'll be using this later in this tutorial.

## Next Steps, Docker Networking
For the next step in the tutorial, head over to [Docker Networking](./networking-basics.md)
