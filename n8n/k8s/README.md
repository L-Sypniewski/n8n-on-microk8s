# Usage
To apply this configuration to your Kubernetes cluster, navigate to the directory containing this kustomization file and run
```sh
kubectl apply -k ./
```

## Security Enhancements

### Enable Secret Encryption at Rest

1. Generate a secure encryption key:
```sh
head -c 32 /dev/urandom | base64
```

2. Add the key to the encryption-config.yaml file

3. Apply the encryption configuration to MicroK8s:
```sh
sudo mkdir -p /var/snap/microk8s/current/args/
sudo cp encryption-config.yaml /var/snap/microk8s/current/args/
sudo echo "--encryption-provider-config=/var/snap/microk8s/current/args/encryption-config.yaml" | sudo tee -a /var/snap/microk8s/current/args/kube-apiserver
sudo microk8s.stop
sudo microk8s.start
```

4. Verify encryption is working:
```sh
# Create a test secret
kubectl create secret generic test-secret -n default --from-literal=key=value
# Check if it's stored encrypted in etcd
sudo microk8s.kubectl get secret test-secret -n default -o yaml
```

5. Re-encrypt existing secrets:
```sh
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

### Secret Rotation Best Practices

1. Periodically update the encryption key in encryption-config.yaml
2. Add the new key at the top of the keys list
3. Re-encrypt all secrets
4. After confirming all secrets are encrypted with the new key, remove the old key
