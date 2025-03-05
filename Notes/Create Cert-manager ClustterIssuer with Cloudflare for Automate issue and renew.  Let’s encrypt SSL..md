
[Create Cert-manager ClustterIssuer with Cloudflare for Automate issue and renew. Let’s encrypt SSL. | by Todsaporn Sangboon | Medium](https://nolifelover.medium.com/create-cert-manager-clustterissuer-with-cloudflare-for-automate-issue-and-renew-lets-encrypt-ssl-4877d3f12b44)


## Properly Formatted Markdown Article

### What is a cert-manager?

At its core, cert-manager is a cloud-native certificate management tool that automatically issues and renews X.509 machine identities as first-class resource types within Kubernetes. To do this, cert-manager needs to be deployed inside a Kubernetes cluster. Once inside, cert-manager can issue and renew certificates for all the machine identities contained within a cluster.

This post will teach us how to create a Let's Encrypt cluster issuer with Cloudflare using DNS challenges.

### Installation and Setup

1. First, You must install cert-manager in your Kubernetes cluster. If you aren't installed, you can install it using Helm charts.

```
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.0
```

2. Second, You must adjust DNS to Cloudflare nameserver by changing your DNS record point to Cloudflare. After that, you must create a Cloudflare Api token for use in cert-manager. Create and verify the domain you want to create an SSL certificate. Go to Cloudflare dashboard > My Profile (Right top corner) > API Tokens. Click Create Token button and Create custom token button. And then, fill Permission section form below.
![[Create Cert-manager ClustterIssuer with Cloudflare for Automate issue and renew.  Let’s encrypt SSL - permissions.png]]

### Cloudflare API Tokens Permission for Using in cert-manager

Check your API token summary like this and click Create Token button. You will receive and copy a new API token for the next step.

### Summarize API token

![[Create Cert-manager ClustterIssuer with Cloudflare for Automate issue and renew.  Let’s encrypt SSL - api token summary.png]]

3. Next, After you get a Cloudflare API token. Now we can create a Kubernetes config for deploying ClustterIssuer with Cloudflare DNS proof.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token
  namespace: cert-manager
type: Opaque
stringData:
  api-token: <Cloudflare API token>
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: <Issuer Name>
spec:
  acme:
    email: <Your Email>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cluster-issuer-account-key
    solvers:
    - dns01:
        cloudflare:
          email: <Your Email>
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-token
```

4. Now you can apply the new ClustterIssuer config to your Kubernetes cluster.

```
kubectl apply -f cloudflare-clustterissuer.yml
kubectl get Clusterissuer -A #checking your cluster issuer
```

### Checking Cluster Issuer

```
NAME                 READY   AGE
cloudflare-issuer     True    28s
```

5. Finally, you can create Ingress with Auto Create Let's Encrypt certificate using the example yaml below. In this example, I use nginx-ingress.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-helloword
  annotations:
    cert-manager.io/cluster-issuer: "cloudflare-issuer"
  namespace: helloword
spec:
  rules:
    - host: api.nolifelover.example
      http:
        paths:
          - backend:
              service:
                port:
                  number: 8080
                name: helloworld-http
            path: /
            pathType: Prefix
  tls:
    - hosts:
        - api.nolifelover.example
      secretName: helloworld-http-tls
  ingressClassName: nginx
```

Save your config and apply it to your Kubernetes cluster.

```
kubectrl apply -f api-helloworld-ingress.yml
kubectl get secrets --field-selector type=kubernetes.io/tls -A #checking your certificate
```

### Checking Certificate

```
NAMESPACE         NAME                          TYPE                DATA   AGE
helloword         helloworld-http-tls           kubernetes.io/tls   2      2m
```