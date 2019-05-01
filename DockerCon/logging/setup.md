## Setup

### Prerequisites
There are no specific skills needed for this tutorial beyond a basic comfort with the command line and using a text editor. Prior experience in developing web applications will be helpful but is not required.

### Play-with-Docker (PWD)

Login to Play-with-Docker [Play-with-Docker](https://dockr.ly/brian)

### Setting up your computer
Getting all the tooling setup on your computer can be a daunting task, but getting Docker up and running on your favorite OS has become very easy.

**Ensure Docker Swarm is enabled**

   ```
   docker swarm init --advertise-addr <your_ip_address>
   ```

The *getting started* guide on Docker has detailed instructions for setting up Docker on [Mac](https://docs.docker.com/docker-for-mac/), [Linux](https://docs.docker.com/engine/installation/linux/) and [Windows](https://docs.docker.com/docker-for-windows/).

*If you're using Docker for Windows* make sure you have [shared your drive](https://docs.docker.com/docker-for-windows/#shared-drives).

*All commands work in either bash or Powershell on Windows*

	Once you are done installing Docker, test your Docker installation by running the following:
	

	```
	docker container run hello-world
	Unable to find image 'hello-world:latest' locally
	latest: Pulling from library/hello-world
	03f4658f8b78: Pull complete
	a3ed95caeb02: Pull complete
	Digest: sha256:8be990ef2aeb16dbcb9271ddfe2610fa6658d13f6dfb8bc72074cc1ca36966a7
	Status: Downloaded newer image for hello-world:latest
	```

	Hello from Docker.
	This message shows that your installation appears to be working correctly.
	...
	
### Start the Docker Pull & deploy

``` 
git clone https://github.com/vegasbrianc/docker-compose-demo.git && cd docker-compose-demo/ && docker-compose pull
```

## Next Steps
For the next step in the tutorial, head over to [Getting Started with Logging](getting-started.md)
