#!/usr/bin/env bash

# microk8s enable helm
microk8s enable dashboard
microk8s enable dns
microk8s enable hostpath-storage
microk8s enable ingress
microk8s enable metallb
microk8s enable rbac
microk8s enable cert-manager
