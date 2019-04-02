# Webapps with Docker Part Deux

Now that we understand the structure of Docker images it's now time to start building our very own Docker image from a `Dockerfile`

> **Tasks**:
>
>
> * [Task 1: Package and run a custom app using Docker](#Task_1)
> * [Task 2: Modify a running website](#Task_2)
> * [Task 3: Create your first image](#Task_3)

**Prerequisite** Ensure you have a DockerID. If you don't have a DockerID you can get one for free via [Docker Cloud](https://cloud.docker.com)

## <a name="Task_1"></a>Task 1: Package and run a custom app using Docker

In this step you'll learn how to package your own apps as Docker images using a [Dockerfile](https://docs.docker.com/engine/reference/builder/).

The Dockerfile syntax is straightforward. In this task we're going to create an NGINX website from a Dockerfile.

### Clone the Lab GitHub Repo

Use the following command to clone the lab repo from GitHub.

```
$ git clone https://github.com/dockersamples/linux_tweet_app
Cloning into 'linux_tweet_app'...
remote: Counting objects: 14, done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 14 (delta 5), reused 14 (delta 5), pack-reused 0
Unpacking objects: 100% (14/14), done.
```

### Build a simple website image

Let's have a look at the  Dockerfile we'll be using, which builds a simple website that allows you to send a tweet.

1. Make sure you're in the `linux_tweet_app` directory:

    ```
    $ cd ~/linux_tweet_app
    ```

2. Display the contents of our Dockerfile.

    ```
    $ cat Dockerfile

    FROM nginx:latest

    COPY index.html /usr/share/nginx/html
    COPY linux.png /usr/share/nginx/html

    EXPOSE 80 443     

    CMD ["nginx", "-g", "daemon off;"]
    ```

    Let's see what each of these lines in the Dockerfile do.

    - [FROM](https://docs.docker.com/engine/reference/builder/#from) specifies the base image to use as the starting point for this new image you're creating. For this example we're starting from `nginx:latest`.
    - [COPY](https://docs.docker.com/engine/reference/builder/#copy) copies files from the host into the image, at a known location. In our case it copies `index.html` and a graphic that will be used on our webpage.
    - [EXPOSE](https://docs.docker.com/engine/reference/builder/#expose) documents which ports the application uses.
    - [CMD](https://docs.docker.com/engine/reference/builder/#cmd) specifies what command to run when a container is started from the image. Notice that we can specify the command, as well as run-time arguments.

3. In order to make commands more copy/paste friendly, export an environment variable containing your DockerID (if you don't have a DockerID you can get one for free via [Docker Hub](https://hub.docker.com))

    ```
    $ export DOCKERID=<your docker id>
    ```

4. To make sure it stored correctly by echoing it back in the terminal

    ```
    $ echo $DOCKERID
    <your docker id>
    ```

5. Use the `docker image build` command to create a new Docker image using the instructions in your Dockerfile.

    * `--tag` allows us to give the image a custom name. In this case it's comprised of our DockerID, the application name, and a version. Having the Docker ID attached to the name will allow us to store it on Docker Hub in a later step
    * `.` tells Docker to use the current directory as the build context

    Be sure to include period (`.`) at the end of the command as this indicates the current directory.

    ```
    $ docker image build --tag $DOCKERID/linux_tweet_app:1.0 .

    Sending build context to Docker daemon  32.77kB
    Step 1/5 : FROM nginx:latest
    latest: Pulling from library/nginx
    afeb2bfd31c0: Pull complete
    7ff5d10493db: Pull complete
    d2562f1ae1d0: Pull complete
    Digest: sha256:af32e714a9cc3157157374e68c818b05ebe9e0737aac06b55a09da374209a8f9
    Status: Downloaded newer image for nginx:latest
    ---> da5939581ac8
    Step 2/5 : COPY index.html /usr/share/nginx/html
    ---> eba2eec2bea9
    Step 3/5 : COPY linux.png /usr/share/nginx/html
    ---> 4d080f499b53
    Step 4/5 : EXPOSE 80 443
    ---> Running in 47232cb5699f
    ---> 74c968a9165f
    Removing intermediate container 47232cb5699f
    Step 5/5 : CMD nginx -g daemon off;
    ---> Running in 4623761274ac
    ---> 12045a0df899
    Removing intermediate container 4623761274ac
    Successfully built 12045a0df899
    Successfully tagged <your docker ID>/linux_tweet_app:latest
    ```

    The output above shows the Docker daemon execute each line in the Dockerfile.

    Feel free to run a `docker image ls` command to see the new image you created.

6. Use the `docker container run` command to start a new container from the image you created.

    As this container will be running an NGINX web server, we'll use the `--publish` flag to publish port 80 inside the container onto port 80 on the host. This will allow traffic coming in to the Docker host on port 80 to be directed to port 80 in the container. The format of the `--publish` flag is `host_port`:`container_port`.

    ```
    $ docker container run \
    --detach \
    --publish 8080:80 \
    --name linux_tweet_app \
    $DOCKERID/linux_tweet_app:1.0
    ```

    Any external traffic coming into the server on port 80 will now be directed into the container.

7. Open your newly created Web App in your Browser `http://0.0.0.0:8080`

8. Once you've accessed the website, shut it down and remove it.

    ```
    $ docker container rm --force linux_tweet_app

    linux_tweet_app
    ```

    > **Note**: We used the `--force` parameter to remove the running container without shutting it down. This will ungracefully shutdown the container and permanently remove it from the Docker host.
    >
    > In a production environment you may want to use `docker container stop` to gracefully stop the container and leave it on the host. You can then use `docker container rm` to permanently remove it.


## <a name="Task_2"></a>Task 2: Modify a running website

When you're actively working on an application it is inconvenient to have to stop the container, rebuild the image, and run a new version every time you make a change to your source code.

One way to streamline this process is to bind mount the source code directory on the local machine into the running container. This will allow any changes made to the files on the host to be immediately reflected in the container.

We do this using something called a [bind mount](https://docs.docker.com/engine/admin/volumes/bind-mounts/).

When you use a bind mount, a file or directory on the host machine is mounted into a container.

### Start a web app with a bind mount

1. Let's start the web app and mount the current directory into the container.

    In this example we'll use the `--mount` flag to mount the current directory on the host into `/usr/share/nginx/html` inside the container.

    Be sure to run this command from within the `linux_tweet_app` directory on your Docker host.

    ```
    $ docker container run \
    --detach \
    --publish 8080:80 \
    --name linux_tweet_app \
    --mount type=bind,source="$(pwd)",target=/usr/share/nginx/html \
    $DOCKERID/linux_tweet_app:1.0
    ```

    > Remember from our Dockerfile `usr/share/nginx/html` is where are html files are stored for our web app

2. Open the Linux_Tweet App in your Browser `http://0.0.0.0:8080` to verify the website is running (you may need to refresh the browser to get the latest version).

### Modify the running website

Because we did a bind mount, any changes made to the local filesystem are immediately reflected in the running container.

3. Copy a new `index.html` into the container.

    The Git repo that you pulled earlier contains several different versions of an index.html file. Run an `ls` command from within the `~/linux_tweet_app` directory to see a list of them. In this step we'll replace `index.html` with `index-new.html`.

    ```
    $ cp index-new.html index.html
    ```

4. Refresh the web page. The site will have changed.

    > Using your favorite editor (vi, emacs, etc) you can use it to load the `index.html` file and make additional real-time changes. Those too would be reflected when you reload the webpage.

    Edit the index.html file and edit line number 33 and change the text to "Docker is Awesome!"
    ```
    $ vi index.html
    ```

    Even though we've modified the `index.html` local filesystem and seen it reflected in the running container, we've not actually changed the original Docker image.

    To show this, let's stop the current container and re-run the `1.0` image without a bind mount.

5. Stop and remove the currently running container

    ```
    $ docker rm --force linux_tweet_app

    linux_tweet_app
    ```

6. Rerun the current version without a bind mount.

    ```
    $ docker container run \
    --detach \
    --publish 8080:80 \
    --name linux_tweet_app \
    $DOCKERID/linux_tweet_app:1.0
    ```

7. Open the Tweet Web App in your Browser `http://0.0.0.0:8080` Notice it's back to the original version with the blue background.

8.  Stop and remove the current container

    ```
    $ docker rm --force linux_tweet_app

    linux_tweet app
    ```

### Update the image

To save the changes you made to the `index.html` file earlier, you need to build a new version of the image.

1. Build a new image and tag it as `2.0`

    Remember that you have previously modified the `index.html` file on the Docker hosts local filesystem. This means that running another `docker image build` will build a new image with the updated `index.html`.

    Be sure to include the period (`.`) at the end of the command.

    ```
    $ docker image build --tag $DOCKERID/linux_tweet_app:2.0 .
    ```

    > Notice how fast that built! This is because Docker only modified the portion of the image that changed vs. rebuilding the whole image.

2. Let's look at the images on our system

    ```
    $ docker image ls
    REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
    <your docker id>/linux_tweet_app   2.0             01612e05312b        16 seconds ago      108MB
    <your docker id>/linux_tweet_app   1.0             bb32b5783cd3        4 minutes ago       108MB
    mysql                          latest              b4e78b89bcf3        2 weeks ago         412MB
    ubuntu                         latest              2d696327ab2e        2 weeks ago         122MB
    nginx                          latest              da5939581ac8        3 weeks ago         108MB
    alpine                         latest              76da55c8019d        3 weeks ago         3.97MB
    ```

    Notice you have both versions of the web app on your host now.

### Test the new version

1. Run a container from the new version of the image.

    Be sure to reference the image tagged as `2.0`.

    ```
    $ docker container run \
    --detach \
    --publish 8080:80 \
    --name linux_tweet_app \
    $DOCKERID/linux_tweet_app:2.0
    ```

2. Open the Tweet Web App in your Browser `http://0.0.0.0:8080`

    The web page will have an orange background.

    We can run both versions side by side. The only thing we need to be aware of is that we cannot have two containers using port 8080 on the same host.

    As we're already using port 8080 for the container running from the `2.0` version of the image, we will start a new container and publish it on port 8081. Additionally, we need to give our container a unique name (`old_linux_tweet_app`)

3. Run the old version (make sure you map it to port 8080 on the host, give it the unique name, and reference  the 1.0 version of the image).

    ```
    $ docker container run \
    --detach \
    --publish 8081:80 \
    --name old_linux_tweet_app \
    $DOCKERID/linux_tweet_app:1.0
    ```

4. Open the Tweet Web App in your Browser `http://0.0.0.0:8081` to view the old version of the website.

Bravo, we have successfully deployed 2 versions of our web app in parralel to our Docker host.

5. Stop the running containers

    ```
    $ docker container ps

    $ docker container stop old_linux_tweet_app

    $ docker container stop linux_tweet_app

### Review

What did we just accomplish? 

1. We created a built a Dockerfile and ran a container from this newly create image
2. Next, we modified the website both the version & index.html file showing real-time updates to the application
3. Finally, we commited our new changes into a newly created image
4. We ran version 1 and version 2 side-by-side


### Dockerfile commands summary

Here's a quick summary of the few basic commands we used in our Dockerfile.

* `FROM` starts the Dockerfile. It is a requirement that the Dockerfile must start with the `FROM` command. Images are created in layers, which means you can use another image as the base image for your own. The `FROM` command defines your base layer. As arguments, it takes the name of the image. Optionally, you can add the Docker Cloud username of the maintainer and image version, in the format `username/imagename:version`.

* `RUN` is used to build up the Image you're creating. For each `RUN` command, Docker will run the command then create a new layer of the image. This way you can roll back your image to previous states easily. The syntax for a `RUN` instruction is to place the full text of the shell command after the `RUN` (e.g., `RUN mkdir /user/local/foo`). This will automatically run in a `/bin/sh` shell. You can define a different shell like this: `RUN /bin/bash -c 'mkdir /user/local/foo'`

* `COPY` copies local files into the container.

* `CMD` defines the commands that will run on the Image at start-up. Unlike a `RUN`, this does not create a new layer for the Image, but simply runs the command. There can only be one `CMD` per a Dockerfile/Image. If you need to run multiple commands, the best way to do that is to have the `CMD` run a script. `CMD` requires that you tell it where to run the command, unlike `RUN`. So example `CMD` commands would be:
```
  CMD ["python", "./app.py"]

  CMD ["/bin/bash", "echo", "Hello World"]
```

* `EXPOSE` creates a hint for users of an image which ports provide services. It is included in the information which
 can be retrieved via `$ docker inspect <container-id>`.     

>**Note:** The `EXPOSE` command does not actually make any ports accessible to the host! Instead, this requires 
publishing ports by means of the `-p` flag when using `$ docker run`.  

* `PUSH` pushes your image to Docker Cloud, or alternately to a [private registry](https://docs.docker.com/registry/)

>**Note:** If you want to learn more about Dockerfiles, check out [Best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/).
Great! So you have now looked at `docker run`, played with a Docker container and also got the hang of some terminology. Armed with all this knowledge, you are now ready to get to the real stuff &#8212; deploying web applications with Docker.


## Next Steps
For the next step in the tutorial head over to [Docker & DevOps](./devops.md)
