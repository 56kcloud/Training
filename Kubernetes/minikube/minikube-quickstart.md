# Minikube Quickstart

minikube is a local k8s enviroemnt for running and testing deployments, there are limitations, but not all k8s feactures are avalaibke. We will obtain a minikube binary for our OS and install the dependencies required to lanch K8s locally

## What is minikube

Minikube is great for having a local deployment of k8s to support testing and building the deployment of your application locally. It not 100% offline but allows for most K8s features to be tested locally


# Download and Install minikube
https://github.com/kubernetes/minikube#installation

#### Requirements: 
Working Hypervisor: virtualbox, KVM, Hyper-V
Linux-Ubuntu: socat "apt-get install socat"

### Links to Binaries

Linux:
OSX:
Windows:

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

	>kubectl create namespace devclube
	># now we use that namespace
	>kubectl run nginx --image nginx --namespace devclub
	>kubectl get pod -n devclub 
	# we should see the nginix pod
    
### Connect to the Dashboard

    # We can have minikube lanch a browerse connected to the kubernetest API
    >minikube dashboard
    ># Browser page should lanche
    ># In the case you are using minikube on a remote systme, it is still possible to access the Dashboard using the kubectl proxy command
    >kubectl proxy & should lanch in background a revser tunnel on ort 8001