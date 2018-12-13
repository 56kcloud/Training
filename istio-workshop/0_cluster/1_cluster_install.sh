#!/bin/bash

PROJECT_NAME


gcloud container clusters create "istio-cluster-1" \
  --project "eighth-duality-607" --zone "europe-north1-a" --username "admin" --cluster-version "1.10.6-gke.6"\
  --machine-type "n1-standard-1" --image-type "COS" --disk-type "pd-standard" \
  --disk-size "20" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
  --min-cpu-platform "Intel Skylake" --num-nodes "4" --enable-cloud-logging --enable-cloud-monitoring  \
  --network "projects/eighth-duality-607/global/networks/k8s-cluster" \
  --subnetwork "projects/eighth-duality-607/regions/europe-north1/subnetworks/subnet-k8s-1" \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair

echo "Cluster admin for me :D"

kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user="$(gcloud config get-value core/account)"
