#!/bin/bash

HOST_IP=35.228.232.253
SSH_KEY=~/.ssh/google_compute_engine
# ssh into host
ssh -i $SSH_KEY $HOST_IP

# start the toolbox
toolbox

# capture paquet
tcpdump not dst port 22 -w /var/log/dump.pcap


exit

exit

CONTAINER_NAME=julien-gcr.io_google-containers_toolbox-20180309-00

scp -i $SSH_KEY $HOST_IP:/var/lib/toolbox/$CONTAINER_NAME/var/log/dump.pcap