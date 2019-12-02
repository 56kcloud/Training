# Docker Networking Basics

In this lab you'll look at the most basic networking components that come with a fresh installation of Docker.

You will complete the following steps as part of this lab.

- [Task 1 - The `docker network` command](#docker_network)
- [Task 2 - List networks](#list_networks)
- [Task 3 - Inspect a network](#inspect)
- [Task 4 - List network driver plugins](#list_drivers)
- [Task 5 - Create Network](#create_network)
- [Task 6 - Remove Network](#remove_network)

# Prerequisites

You will need all of the following to complete this lab:

- A Linux-based Docker Host running Docker 1.12 or higher

# <a name="docker_network"></a>Task 1: The `docker network` command

The `docker network` command is the main command for configuring and managing container networks.

Run a simple `docker network` command from any of your lab machines.

```
$ docker network

Usage:  docker network COMMAND

Manage Docker networks

Options:
      --help   Print usage

Commands:
  connect     Connect a container to a network
  create      Create a network
  disconnect  Disconnect a container from a network
  inspect     Display detailed information on one or more networks
  ls          List networks
  rm          Remove one or more networks

Run 'docker network COMMAND --help' for more information on a command.
```

The command output shows how to use the command as well as all of the `docker network` sub-commands. As you can see from the output, the `docker network` command allows you to create new networks, list existing networks, inspect networks, and remove networks. It also allows you to connect and disconnect containers from networks.

# <a name="list_networks"></a>Task 2: List networks

Run a `docker network ls` command to view existing container networks on the current Docker host.

```
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
1befe23acd58        bridge              bridge              local
726ead8f4e6b        host                host                local
ef4896538cc7        none                null                local
```

The output above shows the container networks that are created as part of a standard installation of Docker.

New networks that you create will also show up in the output of the `docker network ls` command.

You can see that each network gets a unique `ID` and `NAME`. Each network is also associated with a single driver. Notice that the "bridge" network and the "host" network have the same name as their respective drivers.

# <a name="inspect"></a>Task 3: Inspect a network

The `docker network inspect` command is used to view network configuration details. These details include; name, ID, driver, IPAM driver, subnet info, connected containers, and more.

Use `docker network inspect` to view configuration details of the container networks on your Docker host. The command below shows the details of the network called `bridge`.

```
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "1befe23acd58cbda7290c45f6d1f5c37a3b43de645d48de6c1ffebd985c8af4b",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

> **NOTE:** The syntax of the `docker network inspect` command is `docker network inspect <network>`, where `<network>` can be either network name or network ID. In the example above we are showing the configuration details for the network called "bridge". Do not confuse this with the "bridge" driver.


# <a name="list_drivers"></a>Task 4: List network driver plugins

The `docker info` command shows a lot of interesting information about a Docker installation.

Run a `docker info` command on any of your Docker hosts and locate the list of network plugins.

```
$ docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 1.12.3
Storage Driver: aufs
<Snip>
Plugins:
 Volume: local
 Network: bridge host null overlay    <<<<<<<<
Swarm: inactive
Runtimes: runc
<Snip>
```

The output above shows the **bridge**, **host**, **null**, and **overlay** drivers.

# <a name="create_network"></a>Task 5: Create Network

Now we will provision our own network called `my-network` with the following configuration

`--driver` - indicated the network driver to utilize for the network
`--internal` - configures the network as an internal private network with no internet access
`--subnet`- define the subnet of the network
`--ip-range` - IP range available to the containers on this network
`--gateway`- Network gateway to be used


```
$ docker network create \
--driver bridge \
--internal \
--subnet=172.28.0.0/16 \
--ip-range=172.28.5.0/24 \
--gateway=172.28.5.254 \
my-network

d6b825e0fb2d96f13719affc3e7658df2c9dc70ccfb4b9e6405348a1624e5d4b

```

Let's have a look at out newly created network

```
docker network ls                                                                                                                                                                                                                                                                                                                            
NETWORK ID          NAME                DRIVER              SCOPE
4504287a8cd2        bridge              bridge              local
c6282c586073        docker_gwbridge     bridge              local
f0d518128cc6        host                host                local
18789d70fb40        my-network          bridge              local
f806d1a20208        none                null                local
```

Now, inspect `my-network`

```
$ docker network inspect my-network                                                                                                                                                                                                                                                                                                            
[
    {
        "Name": "my-network",
        "Id": "09aefb1784bc64cd8ad9ef1e3a2132fa0812137b1ff8477c73eeb3050f9dcc21",
        "Created": "2019-12-02T10:04:43.300611371Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.28.0.0/16",
                    "IPRange": "172.28.5.0/24",
                    "Gateway": "172.28.5.254"
                }
            ]
        },
        "Internal": true,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]

```

# <a name="delete_network"></a>Task 6: Delete Network

Cleanup the newly create `my-network`


```
$ docker network rm my-network

```

## Next Steps, Web Apps
For the next step in the tutorial, head over to [Webapps with Docker](./webapps.md)
