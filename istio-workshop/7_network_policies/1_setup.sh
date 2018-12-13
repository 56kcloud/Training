#!/bin/bash

kubectl run nginx --image=nginx --replicas=2


kubectl expose deployment nginx --port=80