# k8s-cluster
GitOps for my k8s cluster

## [Launch configuration](https://microk8s.io/docs/add-launch-config)

### Using snap set

It is also possible to set a launch configuration on an existing cluster using the snap set microk8s config=<contents> command.

First, install MicroK8s:

sudo snap install microk8s --classic --channel 1.27

Then, apply the launch configuration by setting the config config option. The option value must be the file contents, not the path:

sudo snap set microk8s config="$(cat microk8s-config.yaml)"

After a while, the configuration is applied to the local node.

## 1. Install microK8s addons

```bash
./cluster/microk8s-install-addons.sh
```

When asked for MetaLB IP range type:
```bash
192.168.1.200-192.168.1.220
```


## 2. Add namespaces

```bash
kubectl apply -f cluster/namespaces.yaml
```

## 4. Create RBAC for Dashboard

**Sometimes `ClusterRoleBinding` already exists:**

```
The ClusterRoleBinding "kubernetes-dashboard" is invalid: roleRef: Invalid value: rbac.RoleRef{APIGroup:"rbac.authorization.k8s.io", Kind:"ClusterRole", Name:"cluster-admin"}: cannot change roleRef`).
```

In such case delete the existing `ClusterRoleBinding`:
```
kubectl delete ClusterRoleBinding kubernetes-dashboard

```bash
kubectl apply -f rbac-dashboard
```

## 5. Install CloudFlare ClusterIssuer
```bash
kubectl apply -f cluster/certificates/cloudflare-cluster-issuer.yaml
```

## 6. Add Ingress

```bash
kubectl apply -f app/ingress.yaml
```

# FAQ

## Unable to connect to the server error

```
Unable to connect to the server: tls: failed to verify certificate: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "10.152.183.1")
```
In such case k8s config has to be reset:
```bash
cd $HOME
mkdir .kube
cd .kube
microk8s config > config
```
