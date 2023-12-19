#!/bin/bash
curl -sfL https://get.k3s.io | sh -
chmod 644 /etc/rancher/k3s/k3s.yaml 
echo export "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /home/ubuntu/.bashrc
echo "alias k=kubectl" >> /home/ubuntu/.bashrc