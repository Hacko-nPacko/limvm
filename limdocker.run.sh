#!/bin/bash
VM="$1"
set -x 
echo "creating lim.vm${VM}"
echo "172.17.0.$((VM+1)) lim.vm${VM}" >> /etc/hosts
mkdir -p /raid0/vms/vm${VM}
docker run -p 1${VM}080:80 -p 1${VM}088:8080 -v=/raid0/vms/shared:/vms/shared -v=/raid0/vms/vm${VM}:/vms/private -it --name vm${VM} --hostname vm${VM} --restart=always niakoi/limvm:latest
