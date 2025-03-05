#kubernetes 

This guide describes how to expose services running in a Microk8s so that they're accessible with a public URL.

# Prerequisites

Before proceeding make sure you've followed [[MicroK8s cluster with load balancer and certificate]] guide as you the following has to be set up:
- Ingress and Ingress Controller - nginx
- Metallb
	- The solution used `metallb` for load balancing. IP range: `192.168.1.200-192.168.1.220`
- Domain has been purchased
- Dynamic DNS to make your device accessible with a domain name 

# Exposing services

In this guide I'll describe two methods of making the services publicly available
- [[Exposing services publicly - MicroK8s#Ingress Controller with Load Balancer Service|Ingress Controller with Load Balancer Service]]
- [[Exposing services publicly - MicroK8s#Load Balancer only|Load Balancer only]]

## Ingress Controller with Load Balancer Service

This is useful if we'd like to use the same Load Balancer to redirect traffic to Kubernetes Services. [[Kubernetes - networking concepts#^d133a2||Each Load Balancer allow us to connect only to a single Service - Ingress doesn't have this limitation]]

### Infrastructure

You should follow [[MicroK8s cluster with load balancer and certificate]] guide first. Once you've finished all the steps you need to redirect the traffic from your router to the Load Balancer.

### Port forwarding

We need to have a public IP of the Load Balancer, obtain it with the following command:
```sh
kubectl get svc --all-namespaces
```

Example output (trimmed):
```sh
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
ingress   LoadBalancer   10.152.183.56   192.168.1.220   80:31247/TCP,443:32526/TCP   116m
```
According to the output we need to redirect the traffic to IP `192.168.1.220` for ports `80` and `443` (http and https).

In the picture below it's shown how to setup port forwarding for my router:
![[port_forwarding_router_orange.png]]

### Firewall

If you cannot connect to your service using the public endpoint check if a firewall (e.g. `ufw`) doesn't block the traffic for given ports. It's also worth defining IP addresses for the rules to minimize the attack surface.

## Load Balancer only

It may happen that you'll have a service you'd like to expose publicly and it already has a Kubernetes Service like #rabbitmq . In such case theres no need to use Ingress as you can redirect traffic directly to service's Service. 

In the previous picture you can see the port forwarding rule for RabbitMQ - the IP is different than the one for Ingress. It IP was obtained with the same command as before:
```sh
kubectl get svc --all-namespaces
```

Example of output:
```sh
NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                         AGE
hello-world-rabbitmq-nodes   ClusterIP      None             <none>          4369/TCP,25672/TCP                                                              23h
service1-service             ClusterIP      10.152.183.194   <none>          80/TCP                                                                          4h41m
service2                     ClusterIP      10.152.183.128   <none>          80/TCP                                                                          3h45m
hello-world-rabbitmq         LoadBalancer   10.152.183.190   192.168.1.200   5672:30402/TCP,15672:32403/TCP,5671:31958/TCP,15671:30123/TCP,15691:32130/TCP   23h
```

The IP for LoadBalancer Service is the one that should be used for port forwarding.

Kubernetes manifest for RabbitMq - **`tls` needs to be set up** for this to work:
```yaml
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  labels:
    app: rabbitmq
  name: hello-world-rabbitmq
  namespace: MY-NAMESPACE
spec:
  replicas: 1
  tls: # Important!
    secretName: test-tls-1
  image: rabbitmq:3.11.15
  service:
    type: LoadBalancer
  persistence:
    storageClassName: microk8s-hostpath
    storage: 10
  rabbitmq:
    additionalConfig: |
      default_user= rabbit
      default_pass = Pass
      default_user_tags.administrator = true
    additionalPlugins:
      - rabbitmq_management
      - rabbitmq_peer_discovery_k8s
```

To connect to a Service exposed with Load Balancer only you need to use your domain address with a given port, e.g. to access RabbitMQ Management UI: `https://mydomain.com:15671` (with or without a trailing slash).

# Examples

You can check out [my forked repo](https://github.com/L-Sypniewski/hellocontainers-arm) for examples.