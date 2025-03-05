#kubernetes 

- [Getting started with MicroK8s on Ubuntu | Gary Woodfine](https://garywoodfine.com/getting-started-with-microk8s-on-unbuntu/)
- [How to access Microk8s dashboard without proxy | Gary Woodfine](https://garywoodfine.com/how-to-access-microk8s-dashboard-without-proxy/)
- [MicroK8s - Addon: dashboard](https://microk8s.io/docs/addon-dashboard)
	- [dashboard/creating-sample-user.md at master · kubernetes/dashboard · GitHub](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)


# Enabling and Accessing Kubernetes Dashboard

Microk8s provides a wide range of add-ons. One of which is the `dashboard` a Kubernetes web-based dashboard. The dashboard allows viewing and interacting with the resources using a GUI.

You will need to enable the dashboard before we can use it

## Enable Kubernetes dashboard

```bash
microk8s enable dashboard
```

I have installed microk8s on a headless server, so will only be able to access the dashboard on a machine on my network using Firefox Browser. To do so I will first need to enable the proxy.

```bash
microk8s dashboard-proxy
```

On doing so the Microk8s will provide you with a system specific token you can use to login on

Checking if Dashboard is running.

Dashboard will be available at https://127.0.0.1:10443


This will provide a token that can be used to login to the dashboard from another machine., using the IP address of my server and the port i.e. `https://192.168.0.35:10443`

[![](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/02/image-2.png?resize=1024%2C452&ssl=1)](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/02/image-2.png?ssl=1)

Paste in the token copied from the terminal window

[![](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/02/image-3.png?resize=1024%2C683&ssl=1)](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/02/image-3.png?ssl=1)

Here we access to the k8s dashboard.

This works great if you're only want to access the dashboard occasionally and you don't want to have it exposed to the network. However, you may want to be able to access the dashboard regularly and have it always available, [How to access Microk8s dashboard without proxy](https://garywoodfine.com/how-to-access-microk8s-dashboard-without-proxy/)

## Conclusion

We have got Microk8s up and running on our local server and we have been able to access our K8s dashboard on another machine. This brings us to the end of this little walk-through I didn't want to over complicate it at this point, because for many folks this is quite a lot to get up to speed with anyway, it certainly was for me!

Checkout [How to access Microk8s dashboard without proxy](https://garywoodfine.com/how-to-access-microk8s-dashboard-without-proxy/) as the next part of this series


# Enable external access to the dashboard

## Enable additional Add-Ons

We will need to enable a few additional Kubernetes add-ons to get this functionality up and running.

```bash
microk8s enable ingress # Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.

microk8s enable dashboard # web-based Kubernetes user interface

microk8s enable dns # creates DNS records for services and pods

microk8s enable hostpath-storage # provide both long-term and temporary storage to Pods in your cluster.
```

In [Getting started with MicroK8s on Ubuntu](https://garywoodfine.com/getting-started-with-microk8s-on-unbuntu) I also provided instructions on [how to Add User Account Microk8s](https://garywoodfine.com/getting-started-with-microk8s-on-unbuntu/#add-user-account-to-microk8s-group) to enable executing `microk8s` commands without `sudo` that is why I am able to execute the above commands. If you have not done this then you will need to prefix the commands with `sudo`

There is not much more configuration we need to do other enable these plugins

## Enable Host Access

We need to alos enable one more additional add-on `host-access` to enable the access to services running on the host machine via fixed IP address.

We can enable to make use of the default address

```bash
microk8s enable host-access
```

## Edit Kubernetes Dashboard Service

We need to edit the kubernetes-dashboard service file which provides dash-board functionality. To to edit this we need to edit dashboard service and change service â€œ**type**â€ from **ClusterIP** to **NodePort**.

We use the following command to edit the file using vim.

```bash
kubectl -n kube-system edit service kubernetes-dashboard
```

This should open the contents of the file in vim and it should look something similar file below

You need to change `type` to `NodePort`
```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"k8s-app":"kubernetes-dashboard"},"name":"kubernetes-dashboard","namespace":"kube-system"},"spec":{"ports":[{"port":443,"targetPort":8443}],"selector":{"k8s-app":"kubernetes-dashboard"}}}
  creationTimestamp: "2022-03-09T14:10:50Z"
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
  resourceVersion: "1029725"
  selfLink: /api/v1/namespaces/kube-system/services/kubernetes-dashboard
  uid: b2608643-a712-4b44-abad-160cf140df49
spec:
  clusterIP: 10.152.183.220
  clusterIPs:
  - 10.152.183.220
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 30536
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: clusterIP                  ## Change this to NodePort
status:
  loadBalancer: {}
```
Once you save and exit the file K8s will automatically restart the service.

We can then get the Port the service is running by using the following command

```bash
kubectl -n kube-system get services
```

Which should display something similar to the below and which we can see that the Dashboard is available on port `30536` in my case

```
NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
metrics-server              ClusterIP   10.152.183.108   <none>        443/TCP                  7d4h
dashboard-metrics-scraper   ClusterIP   10.152.183.170   <none>        8000/TCP                 7d4h
kube-dns                    ClusterIP   10.152.183.10    <none>        53/UDP,53/TCP,9153/TCP   7d4h
kubernetes-dashboard        NodePort    10.152.183.220   <none>        443:30536/TCP            7d4h
```

We can now open our Firefox browser on any workstation on our network and navigate to `https://{server ip}:{port number}` in my case it is `https://192.168.0.35:30536`

[![](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-5.png?resize=1024%2C705&ssl=1)](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-5.png?ssl=1)

## Get the token

[[Dashboard - MicroK8s#Getting a token:]]
~~We need to get the token from the server so we can do so using the following command in the server terminal~~

```bash
token=$(kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
kubectl -n kube-system describe secret $token
```

This should return something similar too

[![](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-6.png?resize=1024%2C303&ssl=1)](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-6.png?ssl=1)

Copy the token text and paste it into the login dialog in the browser

[![](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-7.png?resize=1024%2C371&ssl=1)](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-7.png?ssl=1)

Then you should be able to login with ease.

[![](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-8.png?resize=1024%2C774&ssl=1)](https://i0.wp.com/garywoodfine.com/wp-content/uploads/2022/03/image-8.png?ssl=1)

## Conclusion

Using the above approach will enable access to the Kubernetes dashboard a web-based user interface. You can use Dashboard to deploy containerised applications to a Kubernetes cluster, troubleshoot your containerised application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard.


# Creating a user for the dashboard
It may happen that dashboard doesn't display anything due to lack of permissions. This can be solved:

`service-account.yaml`:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubernetes-dashboard
  namespace: kube-system # In microk8s there's no namespace dedicated for the dashboard
```

`cluster-role-binding.yaml`:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kube-system
```

**Sometimes `ClusterRoleBinding` already exists:**

```
The ClusterRoleBinding "kubernetes-dashboard" is invalid: roleRef: Invalid value: rbac.RoleRef{APIGroup:"rbac.authorization.k8s.io", Kind:"ClusterRole", Name:"cluster-admin"}: cannot change roleRef`).
```

In such case delete the existing `ClusterRoleBinding`:
```
kubectl delete ClusterRoleBinding kubernetes-dashboard
```


#### Getting a token
``` sh
kubectl -n kube-system create token kubernetes-dashboard
```