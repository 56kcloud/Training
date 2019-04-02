# Deploying Webapps with Docker

Great! So you have now looked at `docker container run`, played with a Docker container and also got the hang of some terminology. Armed with all this knowledge, you are now ready to get to the real stuff &#8212; create Docker Images and deploy this images as web application with Docker.

> **Tasks**:
>
>
> * [Task 1: Run a static website in a container](#Task_1)
> * [Task 2: Docker Images](#Task_2)
> * [Task 3: Create your first image](#Task_3)
> * [Understanding Docker Volumes](#understanding-docker-volumes)


### <a name="Task_1"></a>Task 1: Run a static website in a container
>**Note:** Code for this section is in this repo in the [static-site directory](https://github.com/docker/labs/tree/master/beginner/static-site).

First, we'll use Docker to run a static website in a container. The website is based on an existing image. We'll pull a Docker image from Docker Store, run the container, and see how easy it is to set up a web server.

The image that you are going to use is a single-page website that was already created for this demo and is available on the Docker Store as [`dockersamples/static-site`](https://store.docker.com/community/images/dockersamples/static-site). 

1. Run the image directly in one go using `docker run` as follows.

    ```
    $ docker container run --detach dockersamples/static-site
    ```

    >**Note:** The current version of this image doesn't run without the `-d` flag. The `-d` flag enables **detached mode**, which detaches the running container from the terminal/shell and returns your prompt after the container starts. We are debugging the problem with this image but for now, use `-d` even for this first example.

    So, what happens when you run this command?

    Since the image doesn't exist on your Docker host, the Docker daemon first fetches it from the registry and then runs it as a container.

    Now that the server is running, do you see the website? What port is it running on? And more importantly, how do you access the container directly from our host machine?

    Actually, you probably won't be able to answer any of these questions yet! &#9786; In this case, the client didn't tell the Docker Engine to publish any of the ports, so you need to re-run the `docker run` command to add this instruction.

Let's re-run the command with some new flags to publish ports and pass your name to the container to customize the message displayed. We'll use the *-d* option again to run the container in detached mode.

2. Stop the container that you have just launched. In order to do this, we need the container ID.

    Since we ran the container in detached mode, we don't have to launch another terminal to do this. Run `docker container ps` to view the running containers.

    ```
    $ docker container ps
    CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS               NAMES
    a7a0e504ca3e        dockersamples/static-site   "/bin/sh -c 'cd /usr/"   28 seconds ago      Up 26 seconds       80/tcp, 443/tcp     stupefied_mahavira
    ```

3. Check out the `CONTAINER ID` column. You will need to use this `CONTAINER ID` value, a long sequence of characters, to identify the container you want to stop, and then to remove it. The example below provides the `CONTAINER ID` on our system; you should use the value that you see in your terminal.
    
    ```
    $ docker container stop a7a0e504ca3e
    $ docker container rm   a7a0e504ca3e
    ```

    >**Note:** A cool feature is that you do not need to specify the entire `CONTAINER ID`. You can just specify a few starting characters and if it is unique among all the containers that you have launched, the Docker client will intelligently pick it up.

4. Launch a container in **detached** mode as shown below:
    The command summary the above command:

    *  `--detach` will create a container with the process detached from our terminal
    * `-publish-all` will publish all the exposed container ports to random ports on the Docker host
    * `--env` is how you pass environment variables to the container
    * `--name` allows you to specify a container name
    * `AUTHOR` is the environment variable name and `Your Name` is the value that you can pass

    ```
    $ docker container run --name static-site --env AUTHOR="Your Name" --detach --publish-all dockersamples/static-site
    e61d12292d69556eabe2a44c16cbd54486b2527e2ce4f95438e504afb7b02810
    ```


5. Now you can see the ports by running the `docker port` command with the name of the newly create container `static-site`.

    ```
    $ docker port static-site
    443/tcp -> 0.0.0.0:32772
    80/tcp -> 0.0.0.0:32773
    ```

**If you are running [Docker for Mac](https://docs.docker.com/docker-for-mac/), [Docker for Windows](https://docs.docker.com/docker-for-windows/), or Docker on Linux, you can open `http://0.0.0.0:[YOUR_PORT_FOR 80/tcp]`. For our example this is `http://localhost:32773`.**


6. You can also run a second webserver at the same time, this time specifying a custom host port mapping to the container's webserver. **Be sure to change the name**

    ```
    $ docker container run --name static-site-2 --env AUTHOR="Your Name" --detach --publish 8888:80 dockersamples/static-site
    ```

    Open your browser to `http://0.0.0.0:32773` and open a second tab `http://0.0.0.0:8888` We can now view both websites running in parralel on your Docker Host.

<center><img src="../images/web-app.png" title="web-app"></center>

    * `--publish` will publish instruct the container to map the specified container port to the host port. `8888:80` = Host:Container Port

    Now that you've seen how to run a webserver inside a Docker container, how do you create your own Docker image? This is the question we'll explore in the next section.

7. Stop and remove the containers since we won't be using them anymore.

    ```
    $ docker container stop static-site
    $ docker container rm static-site
    ```

8. Let's use a shortcut to remove the second site:

    ```
    $ docker container rm -f static-site-2 static-site-3
    ```
    >**Note:** `rm -f` is the not nice way of removing containers. Be warned

9. Run `docker container ps` to make sure the containers are gone.

    ```
    $ docker container ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    ```

### <a name="Task_2"></a>Task 2: Docker Images

In this section, we dive into Docker images. You will build your own image, use that image to run an application locally, and finally, push the newly create images to Docker Cloud.

The [Docker documentation](https://docs.docker.com/engine/userguide/storagedriver/imagesandcontainers/) gives a great explanation on how storage works with Docker images and containers, but here's the highlights. 

* Images are comprised of layers
* These layers are added by each line in a Dockerfile
* Images on the same host or registry will share layers if possible
* When container is started it gets a unique writeable layer of its own to capture changes that occur while it's running
* Layers exist on the host file system in some form (usually a directory, but not always) and are managed by a [storage driver](https://docs.docker.com/engine/userguide/storagedriver/selectadriver/) to present a logical filesystem in the running container. 
* When a container is removed the unique writeable layer (and everything in it) is removed as well
* To persist data (and improve performance) Volumes are used. 
* Volumes (and the directories they are built on) are not managed by the storage driver, and will live on if a container is removed.  

A Docker image is built up from a series of layers. Each layer represents an instruction in the image’s Dockerfile. Each layer except the very last one is read-only. Consider the following Dockerfile:

```
    FROM ubuntu:15.04
    COPY . /app
    RUN make /app
    CMD python /app/app.py
```

This Dockerfile contains four commands, each of which creates a layer. The `FROM` statement starts out by creating a layer from the ubuntu:15.04 image. The `COPY` command adds some files from your Docker client’s current directory. The `RUN` command builds your application using the make command. Finally, the last layer specifies what command to run within the container. 

<center><img src="../images/container-layers.jpg" title="Container Layers"></center>

Multipe Containers can use the same Image. Each container has its own writable container layer, and all changes are stored in this container layer, multiple containers can share access to the same underlying image and yet have their own data state. The diagram below shows multiple containers sharing the same Ubuntu 15.04 image.

<center><img src="../images/sharing-layers.jpg" title="Sharing Layers"></center>

The following exercises will help to illustrate those concepts in practice. 

Let's start by looking at layers and how files written to a container are managed by something called *copy on write*.

Docker images are the basis of containers. In the previous example, you **pulled** the *dockersamples/static-site* image from the registry and asked the Docker client to run a container **based** on that image. To see the list of images that are available locally on your system, run the `docker images` command.

```
$ docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
dockersamples/static-site   latest              92a386b6e686        2 hours ago        190.5 MB
nginx                       latest              af4b3d7d5401        3 hours ago        190.5 MB
python                      2.7                 1c32174fd534        14 hours ago        676.8 MB
postgres                    9.4                 88d845ac7a88        14 hours ago        263.6 MB
containous/traefik          latest              27b4e0c6b2fd        4 days ago          20.75 MB
node                        0.10                42426a5cba5f        6 days ago          633.7 MB
redis                       latest              4f5f397d4b7c        7 days ago          177.5 MB
mongo                       latest              467eb21035a8        7 days ago          309.7 MB
alpine                      3.3                 70c557e50ed6        8 days ago          4.794 MB
java                        7                   21f6ce84e43c        8 days ago          587.7 MB
```

Above is a list of images that we've pulled from the Docker registry and images I created myself (we'll shortly see how). You will have a different list of images on your machine. The `TAG` refers to a particular snapshot of the image and the `ID` is the corresponding unique identifier or hash for that image.

For simplicity, you can think of an image functions similarly to a git repository - images can be [committed](https://docs.docker.com/engine/reference/commandline/commit/) with changes and have multiple versions. When you do not provide a specific version number, the client defaults to `latest`.

1. Pull a specific version of `ubuntu` image as follows:

    ```
    $ docker image pull ubuntu:12.04
    ```

    *Note* If you do not specify the version number of the image then, as mentioned, the Docker client will default to a version named `latest`.

2. So for example, the `docker image pull` command given below will always pull the `latest` tag of an image. The example below pulls `ubuntu:latest` by default.

    ```
    $ docker image pull ubuntu
    ```

To get a new Docker image you can either get it from a registry (such as the Docker Store) or create your own. There are hundreds of thousands of images available on [Docker Store](https://store.docker.com). You can also search for images directly from the command line using `docker search`.

An important distinction with regard to images is between _base images_ and _child images_.

- **Base images** are images that have no parent images, usually images with an OS like ubuntu, alpine or debian.

- **Child images** are images that build on base images and add additional functionality.

Another key concept is the idea of _official images_ and _user images_. (Both of which can be base images or child images.)

- **Official images** are Docker sanctioned images. Docker, Inc. sponsors a dedicated team that is responsible for reviewing and publishing all Official Repositories content. This team works in collaboration with upstream software maintainers, security experts, and the broader Docker community. These are not prefixed by an organization or user name. In the list of images above, the `python`, `node`, `alpine` and `nginx` images are official (base) images. To find out more about them, check out the [Official Images Documentation](https://docs.docker.com/docker-hub/official_repos/).

- **User images** are images created and shared by users like you. They build on base images and add additional functionality. Typically these are formatted as `user/image-name`. The `user` value in the image name is your Docker Store user or organization name.

### <a name="Task_3"></a>Task 3: Create your first image


## Layers and Copy on Write


1. Pull the Debian:Stretch image

    ```
    $ docker image pull debian:stretch-slim
    jessie: Pulling from library/debian
    85b1f47fba49: Pull complete
    Digest: sha256:f51cf81db2de8b5e9585300f655549812cdb27c56f8bfb992b8b706378cd517d
    Status: Downloaded newer image for debian:jessie
    ```

2. Pull a MySQL image

    ```
    $ docker image pull mysql
    Using default tag: latest
    latest: Pulling from library/mysql
    85b1f47fba49: Already exists
    27dc53f13a11: Pull complete
    095c8ae4182d: Pull complete
    0972f6b9a7de: Pull complete
    1b199048e1da: Pull complete
    159de3cf101e: Pull complete
    963d934c2fcd: Pull complete
    f4b66a97a0d0: Pull complete
    f34057997f40: Pull complete
    ca1db9a06aa4: Pull complete
    0f913cb2cc0c: Pull complete
    Digest: sha256:bfb22e93ee87c6aab6c1c9a4e7cdc68e9cb9b64920f28fa289f9ffae9fe8e173
    Status: Downloaded newer image for mysql:latest
    ```

    What do you notice about those the output from the Docker pull request for MySQL?

    The first layer pulled says:

    `85b1f47fba49: Already exists`

    Notice that the layer id (`85b1f47fba498`) is the same for the first layer of the MySQl image and the only layer in the Debian:Jessie image. And because we already had pulled that layer when we pulled the Debian image, we didn't have to pull it again. 

    So, what does that tell us about the MySQL image? Since each layer is created by a line in the image's *Dockerfile*, we know that the MySQL image is based on the Debian:Jessie base image. We can confirm this by looking at the [Dockerfile on Docker Store](https://github.com/docker-library/mysql/blob/0590e4efd2b31ec794383f084d419dea9bc752c4/5.7/Dockerfile). 

    The first line in the the Dockerfile is: `FROM debian:jessie` This will import that layer into the MySQL image. 

    So layers are created by Dockerfiles and are are shared between images. When you start a container, a writeable layer is added to the base image. 

    Next you will create a file in our container, and see how that's represented on the host file system. 

3. Start a Debian container, shell into it.   

    ```
    $ docker run --tty --interactive --name debian debian:stretch-slim bash
    root@e09203d84deb:/#
    ```

4. Create a file and then list out the directory to make sure it's there:

    ```
    root@e09203d84deb:/# touch test-file
    root@e09203d84deb:/# ls
    bin   dev  home  lib64  mnt  proc  run   srv  test-file  usrboot  etc  lib   media  opt  root  sbin  sys  tmp        var
    ```

    We can see  `test-file` exists in the root of the containers file system. 

    What has happened is that when a new file was written to the disk, the Docker storage driver placed that file in it's own layer. This is called *copy on write* - as soon as a change is detected the change is copied into the writeable layer. That layers is represented by a directory on the host file system. All of this is managed by the Docker storage driver. 

5. Exit the container but leave it running by pressing `ctrl-p` and then `ctrl-q`

<center><img src="../images/overlay_constructs.jpg" title="Overlay Constructs"></center>

    Our Docker host utilizes OverlayFS with the [overlay2](https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/#how-the-overlay2-driver-works) storage driver. 

    OverlayFS layers two directories on a single Linux host and presents them as a single directory. These directories are called layers and the unification process is referred to as a union mount. OverlayFS refers to the lower directory as lowerdir and the upper directory a upperdir. "Upper" and "Lower" refer to when the layer was added to the image. In our example the writeable layer is the most "upper" layer.  The unified view is exposed through its own directory called merged. 

6. Stop the contianer

    ```
    $ docker container stop debian
    ```

7. Ensure that your debian container still exists

    ```
    $ docker container ls --all
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS           PORTS               NAMES
    674d7abf10c6        debian:stretch-slim "bash"              36 minutes ago      Exited (0) 2 minutes ago                       debian
    ```

8. Sart the Debian container again

    ```
    $ docker container start debian
    ```

8. Attach to the Debian container hit `enter` twice after completing the command

    ```
    $ docker container attach debian
    ```


    Because the container still exists, the files are still available on  your file system. At this point the file we created previously still exists.

    However, if we remove the container, the directories on the host file system will be removed, and your changes will be gone

13. Remove the container and list the directory contents

    ```
    $ docker container rm debian
    debian
    ```

    The files that were created are now gone and the container now reverts back to the base image which it was created from if we start it again.


## Understanding Docker Volumes

[Docker volumes](https://docs.docker.com/engine/admin/volumes/volumes/) are directories on the host file system that are not managed by the storage driver. Since they are not managed by the storage drive they offer a couple of important benefits. 

* **Performance**: Because the storage driver has to create the logical filesystem in the container from potentially many directories on the local host, accessing data can be slow. Especially if there is a lot of write activity to that container. In fact you should try and minimize the amount of writes that happen to the container's filesystem, and instead direct those writes to a volume

* **Persistence**: Volumes are not removed when the container is deleted. They exist until explicitly removed. This means data written to a volume can be reused by other containers. 

Volumes can be anonymous or named. Anonymous volumes have no way for the to be explicitly referenced. They are almost exclusively used for performance reasons as you cannot persist data effectively with anonymous volumes. Named volumes can be explicitly referenced so they can be used to persist data and increase performance. 

The next sections will cover both anonymous and named volumes. 

> Special Note: These next sections were adapted from [Arun Gupta's](https://twitter.com/arungupta) excellent [tutorial](http://blog.arungupta.me/docker-mysql-persistence/) on persisting data with MySQL. 

### Anonymous Volumes

Take a look at the MySQL [Dockerfile](https://github.com/docker-library/mysql/blob/0590e4efd2b31ec794383f084d419dea9bc752c4/5.7/Dockerfile) you will find the following line:

```
VOLUME /var/lib/mysql
```

This line sets up an anonymous volume in order to increase database performance by avoiding sending a bunch of writes through the Docker storage driver.

Note: An anonymous volume is a volume that hasn't been explicitly named. This means that it's extremely difficult to use the volume later with a new container. Named volumes solve that problem, and will be covered later in this section. 


1. Start a MySQL container

    ```
    $ docker run --name mysqldb -e MYSQL_USER=mysql -e MYSQL_PASSWORD=mysql -e MYSQL_DATABASE=sample -e MYSQL_ROOT_PASSWORD=supersecret -d mysql
    acf185dc16e274b2f332266a1bfc6d1df7d7b4f780e6a7ec6716b40cafa5b3c3
    ```

    When we start the container the anonymous volume is created:

2. Use Docker inspect to view the details of the anonymous volume


    ```
    $ docker inspect -f 'in the {{.Name}} container {{(index .Mounts 0).Destination}} is mapped to {{(index .Mounts 0).Source}}' mysqldb
    ```

    This command will return: `in the /mysqldb container /var/lib/mysql is mapped to /var/lib/docker/volumes/cd79b3301df29d13a068d624467d6080354b81e34d794b615e6e93dd61f89628/_data`

    As mentined anonymous volumes will not persist data between containers, they are almost always used to increase performance. 

3. Shell into your running MySQL container and log into MySQL

    ```
    $ docker exec --tty --interactive mysqldb bash

    root@132f4b3ec0dc:/# mysql --user=mysql --password=mysql
    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 3
    Server version: 5.7.19 MySQL Community Server (GPL)

    Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    ```

4. Create a new table

    ```
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | sample             |
    +--------------------+
    2 rows in set (0.00 sec)

    mysql> connect sample;
    Connection id:    4
    Current database: sample

    mysql> show tables;
    Empty set (0.00 sec)

    mysql> create table user(name varchar(50));
    Query OK, 0 rows affected (0.01 sec)

    mysql> show tables;
    +------------------+
    | Tables_in_sample |
    +------------------+
    | user             |
    +------------------+
    1 row in set (0.00 sec)
    ```

5. Exit MySQL and the MySQL container. 

    ```
    mysql> exit
    Bye

    root@132f4b3ec0dc:/# exit
    exit
    ```

6. Stop the container and restart it

    ```
    $ docker stop mysqldb
    mysqldb

    $ docker start mysqldb
    mysqldb
    ```

7. Shell back into the running container and log into MySQL

    ```
    $ docker exec --interactive --tty mysqldb bash

    root@132f4b3ec0dc:/# mysql --user=mysql --password=mysql
    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 3
    Server version: 5.7.19 MySQL Community Server (GPL)

    Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    ```

8. Ensure the table created previously table still exists

    ```
    mysql> connect sample;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Connection id:    4
    Current database: sample

    myslq> show tables;
    +------------------+
    | Tables_in_sample |
    +------------------+
    | user             |
    +------------------+
    1 row in set (0.00 sec)
    ```

9. Exit MySQL and the MySQL container. 

    ```
    mysql> exit
    Bye

    root@132f4b3ec0dc:/# exit
    exit
    ```

    The table persisted across container restarts, which is to be expected. In fact, it would have done this whether or not we had actually used a volume as shown in the previous section. 

10. Let's look at the volume again

    ```
    $ docker inspect -f 'in the {{.Name}} container {{(index .Mounts 0).Destination}} is mapped to {{(index .Mounts 0).Source}}' mysqldb
    in the /mysqldb container /var/lib/mysql is mapped to /var/lib/docker/volumes/cd79b3301df29d13a068d624467d6080354b81e34d794b615e6e93dd61f89628/_data
    ```

    We do see the volume was not affected by the container restart either. 

    Where people often get confused is in expecting that the anonymous volume can be used to persist data BETWEEN containers. 

    To examine that delete the old container, create a new one with the same command, and check to see if the table exists. 

11. Remove the current MySQL container

    ```
    $ docker container rm --force mysqldb
    mysqldb
    ```

12. Start a new container with the same command that was used before

    ```
    $ docker run --name mysqldb -e MYSQL_USER=mysql -e MYSQL_PASSWORD=mysql -e MYSQL_DATABASE=sample -e MYSQL_ROOT_PASSWORD=supersecret -d mysql
    eb15eb4ecd26d7814a8da3bb27cee1a23304fab1961358dd904db37c061d3798
    ```

13. List out the volume details for the new container

    ```
    $ docker inspect -f 'in the {{.Name}} container {{(index .Mounts 0).Destination}} is mapped to {{(index .Mounts 0).Source}}' mysqldb
    in the /mysqldb container /var/lib/mysql is mapped to /var/lib/docker/volumes/e0ffdc6b4e0cfc6e795b83cece06b5b807e6af1b52c9d0b787e38a48e159404a/_data
    ```

    Notice this directory is different than before. 

14. Shell back into the running container and log into MySQL

    ```
    $ docker exec --interactive --tty mysqldb bash

    root@132f4b3ec0dc:/# mysql --user=mysql --password=mysql
    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 3
    Server version: 5.7.19 MySQL Community Server (GPL)

    Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    ```

15. Check to see if table created previously table still exists

    ```
    mysql> connect sample;
    Connection id:    4
    Current database: sample

    mysql> show tables;
    Empty set (0.00 sec)
    ```

16. Exit MySQL and the MySQL container. 

    ```
    mysql> exit
    Bye

    root@132f4b3ec0dc:/# exit
    exit
    ```

17. Remove the container

    ```
    docker container rm --force mysqldb
    mysqldb
    ```

So while a volume was used to store the new table in the original container, because it wasn't a named volume the data could not be persisted between containers. 

To achieve persistence a named volume should be used.

### Named Volumes

A named volume (as the name implies) is a volume that's been explicitly named and can easily be referenced. 

A named volume can be create on the command line, in a docker-compose file, and when you start a new container. They [CANNOT be created as part of the image's dockerfile](https://github.com/moby/moby/issues/30647). 

1. Start a MySQL container with a named volume (`dbdata`)

    ```
    $ docker run --name mysqldb \
    -e MYSQL_USER=mysql \
    -e MYSQL_PASSWORD=mysql \
    -e MYSQL_DATABASE=sample \
    -e MYSQL_ROOT_PASSWORD=supersecret \
    --detach \
    --mount type=volume,source=mydbdata,target=/var/lib/mysql \
    mysql
    ```

    Because the newly created volume is empty, Docker will copy over whatever existed in the container at `/var/lib/mysql` when the container starts. 

    Docker volumes are primatives just like images and containers. As such, they can be listed and removed in the same way. 

2. List the volumes on the Docker host

    ```
    $ docker volume ls
    DRIVER              VOLUME NAME
    local               55c322b9c4a644a5284ccb5e4d7b6b466a0534e26d57c9ef4221637d39cf9a88
    local               cc44059d23e0a914d4390ea860fd35b2acdaa480e83c025fb381da187b652a66
    local               e0ffdc6b4e0cfc6e795b83cece06b5b807e6af1b52c9d0b787e38a48e159404a
    local               mydbdata
    ```

3. Inspect the volume

    ```
    $ docker inspect mydbdata
    [
        {
            "CreatedAt": "2017-10-13T19:55:10Z",
            "Driver": "local",
            "Labels": null,
            "Mountpoint": "/var/lib/docker/volumes/mydbdata/_data",
            "Name": "mydbdata",
            "Options": {},
            "Scope": "local"
        }
    ]
    ```

    Any data written to `/var/lib/mysql` in the container will be rerouted to `/var/lib/docker/volumes/mydbdata/_data` instead. 

4. Shell into your running MySQL container and log into MySQL

    ```
    $ docker exec --tty --interactive mysqldb bash

    root@132f4b3ec0dc:/# mysql --user=mysql --password=mysql
    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 3
    Server version: 5.7.19 MySQL Community Server (GPL)

    Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    ```

5. Create a new table

    ```
    mysql> connect sample;
    Connection id:    4
    Current database: sample

    mysql> show tables;
    Empty set (0.00 sec)

    mysql> create table user(name varchar(50));
    Query OK, 0 rows affected (0.01 sec)

    mysql> show tables;
    +------------------+
    | Tables_in_sample |
    +------------------+
    | user             |
    +------------------+
    1 row in set (0.00 sec)
    ```

6. Exit MySQL and the MySQL container. 

    ```
    mysql> exit
    Bye

    root@132f4b3ec0dc:/# exit
    exit
    ```

7. Remove the MySQL container

    ```
    $ docker container rm --force mysqldb
    ```

    Because the MySQL was writing out to a named volume, we can start a new container with the same data. 

    When the container starts it will not overwrite existing data in a volume. So the data created in the previous steps will be left intact and mounted into the new container. 

8. Start a new MySQL container

    ```
    $ docker run --name new_mysqldb \
    -e MYSQL_USER=mysql \
    -e MYSQL_PASSWORD=mysql \
    -e MYSQL_DATABASE=sample \
    -e MYSQL_ROOT_PASSWORD=supersecret \
    --detach \
    --mount type=volume,source=mydbdata,target=/var/lib/mysql \
    mysql
    ```

9. Shell into your running MySQL container and log into MySQL

    ```
    $ docker exec --tty --interactive new_mysqldb bash

    root@132f4b3ec0dc:/# mysql --user=mysql --password=mysql
    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 3
    Server version: 5.7.19 MySQL Community Server (GPL)

    Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    ```

10. Check to see if the previously created table exists in your new container.

    ```
    mysql> connect sample;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Connection id:    4
    Current database: sample

    mysql> show tables;
    +------------------+
    | Tables_in_sample |
    +------------------+
    | user             |
    +------------------+
    1 row in set (0.00 sec)
    ```

    The data will exist until the volume is explicitly deleted. 

11. Exit MySQL and the MySQL container. 

    ```
    mysql> exit
    Bye

    root@132f4b3ec0dc:/# exit
    exit
    ```

12. Remove the new MySQL container and volume

    ```
    $ docker container rm --force new_mysqldb
    new_mysqldb

    $ docker volume rm mydbdata
    mydbdata
    ```

    If a new container was started with the previous command, it would create a new empty volume. 


## Let's Take a Break then continue to Part 2
For the next step in the tutorial head over to [WebApps Part Deux](./webapps-part2.md)
