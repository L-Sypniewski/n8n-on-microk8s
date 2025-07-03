# Security Guidelines

This document outlines the security configurations and best practices implemented in this n8n on MicroK8s deployment.

## Security Enhancements Implemented

### 1. Container Security Context
- **Non-root execution**: Containers run as user ID 1000 (non-root)
- **Privilege restrictions**: `allowPrivilegeEscalation: false`
- **Capability dropping**: All unnecessary Linux capabilities are dropped
- **File system group**: Proper `fsGroup` for volume permissions

### 2. Secret Management
- **Base64 encoded secrets**: All sensitive data is properly base64 encoded
- **Clear documentation**: Instructions for generating secure encryption keys
- **Placeholder warnings**: Clear warnings to replace placeholder values
- **Separation of concerns**: Secrets are separated from configuration

### 3. Network Security  
- **HTTPS enforcement**: SSL redirect enabled in ingress
- **Security headers**: XSS protection, content type options, HSTS
- **Certificate management**: Automated Let's Encrypt certificates via cert-manager

### 4. RBAC (Role-Based Access Control)
- **Minimal permissions**: Service accounts have only necessary permissions
- **Scoped access**: Roles are namespace-scoped where possible
- **Specific resource access**: Only required secrets are accessible

### 5. Resource Management
- **Resource limits**: CPU and memory limits prevent resource exhaustion
- **Resource requests**: Ensures proper scheduling and resource allocation

## Required Manual Configuration

### Before Deployment

1. **Generate Encryption Key**:
   ```bash
   head -c 32 /dev/urandom | base64 -w 0
   ```
   Update `n8n/k8s/secret.yaml` with the generated key.

2. **Cloudflare API Token**:
   - Generate token at: https://dash.cloudflare.com/profile/api-tokens
   - Required permissions: `Zone:DNS:Edit`, `Zone:Zone:Read` for all zones
   - Update `cluster/certificates/cloudflare-cluster-issuer.yaml`

3. **Email Configuration**:
   - Replace `REPLACE_WITH_YOUR_EMAIL@example.com` in cluster issuer configuration
   - This email is used for Let's Encrypt certificate notifications

4. **Domain Configuration**:
   - Update `n8n.mydomain.dev` in ingress and configmap to your actual domain
   - Ensure DNS points to your cluster's external IP

## Security Checklist

- [ ] Replaced placeholder tokens with actual values
- [ ] Generated secure encryption key for n8n
- [ ] Configured proper domain names
- [ ] Verified RBAC permissions are minimal
- [ ] Enabled network policies (if supported)
- [ ] Regular secret rotation scheduled
- [ ] Backup encryption keys securely stored
- [ ] Monitor for security updates in base images

## Monitoring and Maintenance

1. **Regular Updates**: Keep container images updated
2. **Secret Rotation**: Rotate encryption keys periodically
3. **Certificate Monitoring**: Monitor Let's Encrypt certificate renewals
4. **Access Reviews**: Regularly review RBAC permissions
5. **Security Scanning**: Scan images for vulnerabilities

## Emergency Procedures

1. **Compromised Secret**: Immediately rotate affected secrets
2. **Certificate Issues**: Check cert-manager logs and DNS configuration
3. **Access Issues**: Review RBAC configurations and service account permissions

For questions or security concerns, review the implementation in the respective YAML files.