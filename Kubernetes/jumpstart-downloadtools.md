# JumpStart Guide
This quick HOWTO is to support downloading the starting the K8s LAB and tools quickly while readly avaliable internet is possilbe

Explaintions are not givien as this information is NOT to support How but to allos a user to Copy/Past the contnet this neeed to quickly get there enviroment setup effectivitly while access to a fest internet is possible

## Tools
 - minikube
 - kubectl
 - kops
 - helm
 - Hypervisor (Virtualbox, KVM, ..)
 - nice to have:
    - jq, zsh, zsh completion for kubectl

## Requirements
Depending on your local OS, this will vary and will require some searching for software packages that are required for your platform. We try to address the common three, but problems with this will forsure persue

At least 4GB of RAM avalaible, 2-Core Hyperthread, and 100GB of data
Local Administrator Rights, and/or Sudo
Fast internet, 50Mbits+ possible over WLAN, 500MB~1.GB of data to download. (takes 10mins)

 - A Hypervisor

## Download and Install




## Execute tools

It's important to start the tools at lesat once so further packages and docker images can be downloaded, 'minikube start' will begin download an ISO and create a VM to host the docker machine


kukubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

