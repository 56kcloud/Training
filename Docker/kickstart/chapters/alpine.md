## 1.0 Running your first container

Now that you have everything setup, it's time to get our hands dirty. In this section, you are going to run an [Alpine Linux](http://www.alpinelinux.org/) container (a lightweight linux distribution) on your system and get a taste of the `docker run` command.

To get started, let's run the following in our terminal:
```
$ docker pull alpine
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
88286f41530e: Pull complete
Digest: sha256:f006ecbb824d87947d0b51ab8488634bf69fe4094959d935c0c103f4820a417d
Status: Downloaded newer image for alpine:latest
```

> **Note:** Depending on how you've installed docker on your system, you might see a `permission denied` error after running the above command. Try the commands from the Getting Started tutorial to [verify your installation](https://docs.docker.com/engine/getstarted/step_one/#/step-3-verify-your-installation). If you're on Linux, you may need to prefix your `docker` commands with `sudo`. Alternatively you can [create a docker group](https://docs.docker.com/engine/installation/linux/ubuntulinux/#/create-a-docker-group) to get rid of this issue.

The `pull` command fetches the alpine **image** from the **Docker registry** and saves it in our system. You can use the `docker images` command to see a list of all images on your system.

```
$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
alpine                  latest              3fd9065eaf02        2 weeks ago         4.15MB
hello-world             latest              f2a91732366c        2 months ago        1.85kB
```

### 1.1 Run a single-task Alpine Linux Container

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

List all containers

```
$ docker container ls --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS            PORTS               NAMES
888e89a3b36b        alpine              "hostname"          50 seconds ago      Exited (0) 49 seconds ago                       awesome_elion
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

Try another command.
```
$ docker container run alpine /bin/sh
```

Wait, nothing happened! Is that a bug? Well, no. These interactive shells will exit after running any scripted commands, unless they are run in an interactive terminal - so for this example to not exit, you need to `docker run -it alpine /bin/sh`.

You are now inside the container shell and you can try out a few commands like `ls -l`, `uname -a` and others. Exit out of the container by giving the `exit` command.


Ok, now it's time to see the `docker ps` command. The `docker ps` command shows you all containers that are currently running.

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

Since no containers are running, you see a blank line. Let's try a more useful variant: `docker ps -a`

```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
36171a5da744        alpine              "/bin/sh"                5 minutes ago       Exited (0) 2 minutes ago                        fervent_newton
a6a9d46d0b2f        alpine             "echo 'hello from alp"    6 minutes ago       Exited (0) 6 minutes ago                        lonely_kilby
ff0a5c3750b9        alpine             "ls -l"                   8 minutes ago       Exited (0) 8 minutes ago                        elated_ramanujan
c317d0a9e3d2        hello-world         "/hello"                 34 seconds ago      Exited (0) 12 minutes ago                       stupefied_mcclintock
```

What you see above is a list of all containers that you ran. Notice that the `STATUS` column shows that these containers exited a few minutes ago. You're probably wondering if there is a way to run more than just one command in a container. Let's try that now:

```
$ docker run -it alpine /bin/sh
/ # ls
bin      dev      etc      home     lib      linuxrc  media    mnt      proc     root     run      sbin     sys      tmp      usr      var
/ # uname -a
Linux 97916e8cb5dc 4.4.27-moby #1 SMP Wed Oct 26 14:01:48 UTC 2016 x86_64 Linux
```
Running the `run` command with the `-it` flags attaches us to an interactive tty in the container. Now you can run as many commands in the container as you want. Take some time to run your favorite commands.

That concludes a whirlwind tour of the `docker run` command which would most likely be the command you'll use most often. It makes sense to spend some time getting comfortable with it. To find out more about `run`, use `docker run --help` to see a list of all flags it supports. As you proceed further, we'll see a few more variants of `docker run`.


### Run an interactive Ubuntu container

You can run a container based on a different version of Linux than is running on your Docker host.

In the next example, we are going to run an Ubuntu Linux container on top of an Alpine Linux Docker host (Play With Docker uses Alpine Linux for its nodes).

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
    - `cat /etc/issue` - shows which Linux distro the container is running, in this case Ubuntu 16.04 LTS

3. Type `exit` to leave the shell session. This will terminate the `bash` process, causing your container to exit.

    > **Note:** As we used the `--rm` flag when we started the container, Docker removed that container when it stopped. This means if you run another `docker container ls --all` you won't see the Ubuntu container.

4. For fun, let's check the version of our host VM

    ```
    $ cat /etc/issue

    Welcome to Alpine Linux 3.6
    Kernel \r on an \m (\l)
    ```

    Notice that our host VM is Alpine, yet we were able to run an Ubuntu container. As previously mentioned, the distribution of Linux in the container does not need to match the distribution of Linux running on the Docker host.

    However, Linux containers require the Docker host to be running a Linux kernel. For example, Linux containers cannot run directly on Windows Docker hosts. The same is true of Windows containers - they need to run on a Docker host with a Windows kernel.

Interactive containers are useful when you are putting together your own image. You can run a container and verify all the steps you need to deploy your app, and capture them in a Dockerfile.

> **Note:** You *can* [commit](https://docs.docker.com/engine/reference/commandline/commit/) a container to make an image from it - but you should avoid that wherever possible. It's much better to use a repeatable [Dockerfile](https://docs.docker.com/engine/reference/builder/) to build your image. You'll see that shortly.

5. To exit the shell of the Ubunutu container:

	```
	$ exit
	```

We can exit the TTY of the container with by typing `exit` or `CTRL-D`

### Terminology
In the last section, you saw a lot of Docker-specific jargon which might be confusing to some. So before you go further, let's clarify some terminology that is used frequently in the Docker ecosystem.

- *Images* - The file system and configuration of our application which are used to create containers. To find out more about a Docker image, run `docker inspect alpine`. In the demo above, you used the `docker pull` command to download the **alpine** image. When you executed the command `docker run hello-world`, it also did a `docker pull` behind the scenes to download the **hello-world** image.
- *Containers* - Running instances of Docker images &mdash; containers run the actual applications. A container includes an application and all of its dependencies. It shares the kernel with other containers, and runs as an isolated process in user space on the host OS. You created a container using `docker run` which you did using the alpine image that you downloaded. A list of running containers can be seen using the `docker ps` command.
- *Docker daemon* - The background service running on the host that manages building, running and distributing Docker containers.
- *Docker client* - The command line tool that allows the user to interact with the Docker daemon.
- *Docker Store* - A [registry](https://store.docker.com/) of Docker images, where you can find trusted and enterprise ready containers, plugins, and Docker editions. You'll be using this later in this tutorial.

## Next Steps
For the next step in the tutorial, head over to [2.0 Webapps with Docker](./webapps.md)
