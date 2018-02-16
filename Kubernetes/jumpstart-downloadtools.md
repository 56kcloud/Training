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

#### Requirements: 
Working Hypervisor: virtualbox, KVM, Hyper-V
Linux-Ubuntu: socat "apt-get install socat"

### Links to Binaries

Linux:

	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
 
	brew update && brew install kops

OSX:

    brew cask install minikube
    brew install kubernetes-cli

Windows: https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe

Kops is not supported on Windows :(

### Starting minikube

	cd/ into the DIR where minikube is (best in a new directory)
    minikube start                                                   
    Starting local Kubernetes v1.9.0 cluster...           
    Starting VM...                                          
    Downloading Minikube ISO                                                         
     142.22 MB / 142.22 MB [============================================] 100.00% 0s
    Getting VM IP address...                              
    Moving files into cluster...                                                                    
    Downloading localkube binary                                                              
     162.41 MB / 162.41 MB [============================================] 100.00% 0s      
     65 B / 65 B [======================================================] 100.00% 0s                         
    Setting up certs...                                         
    Connecting to cluster...                                        
    Setting up kubeconfig...                                                    
    Starting cluster components...                                                                           
    Kubectl is now configured to use the cluster.                                      
    Loading cached images from config file.        
    >minikube start
    >minikube status
    minikube: Running
    cluster: Running
    kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100

### Testing Minikube
We can quickly test minikube by running an image, 

	>kubectl create namespace devclub
	># now we use that namespace
	>kubectl run nginx --image nginx --namespace devclub
	>kubectl get pod -n devclub 
	# we should see the nginix pod

## Execute tools

It's important to start the tools at lesat once so further packages and docker images can be downloaded, 'minikube start' will begin download an ISO and create a VM to host the docker machine


kukubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

