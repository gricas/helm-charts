# n8n Helm Chart

A Helm chart for deploying n8n workflow automation platform to Kubernetes.

## Overview

n8n is a workflow automation platform that allows you to connect different services and automate tasks. This Helm chart provides a production-ready deployment of n8n on Kubernetes with optional PostgreSQL database support.

## Chart Details

- **Chart Name**: n8n-helm
- **Version**: 0.1.0
- **App Version**: 0.1.0
- **n8n Image**: n8nio/n8n:latest

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- PV provisioner support in the underlying infrastructure (for persistent storage)

## Installation

### Quick Start

```bash
helm install n8n-release .
```

### With Custom Values

```bash
helm install n8n-release . -f my-values.yaml
```

### Using PostgreSQL Database

```bash
helm install n8n-release . --set postgresql.enabled=true --set n8n.database.type=postgresdb
```

## Configuration

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | n8n image repository | `n8nio/n8n` |
| `image.tag` | n8n image tag | `latest` |
| `replicaCount` | Number of n8n replicas | `1` |
| `service.type` | Kubernetes service type | `NodePort` |
| `service.port` | Service port | `5678` |
| `service.nodePort` | NodePort for external access | `30678` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | Storage size | `5Gi` |
| `n8n.database.type` | Database type (sqlite/postgresdb) | `sqlite` |
| `n8n.webhookUrl` | External webhook URL | `http://n8n.local:$NODEPORT` |
| `postgresql.enabled` | Enable PostgreSQL dependency | `false` |

### Database Configuration

#### SQLite (Default)
```yaml
n8n:
  database:
    type: "sqlite"
```

#### PostgreSQL
```yaml
n8n:
  database:
    type: "postgresdb"
    host: "postgresql"
    port: 5432
    database: "n8n"
    username: "n8n"
    password: "password"

postgresql:
  enabled: true
  auth:
    database: "n8n"
    username: "n8n"
    password: "n8npassword"
```

### Ingress Configuration

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: n8n.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: n8n-tls
      hosts:
        - n8n.example.com
```

### Resource Configuration

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 1024Mi
```

## Accessing n8n

### NodePort (Default)
The chart exposes n8n via NodePort on port 30678 by default:
```bash
http://<node-ip>:30678
```

### Port Forwarding
```bash
kubectl port-forward svc/n8n-release 5678:5678
```
Then access: http://localhost:5678

### Ingress
Configure ingress settings in values.yaml for external domain access.

## Persistence

By default, the chart creates a PersistentVolumeClaim with 5Gi storage mounted at `/home/node/.n8n`. This stores:
- Workflow data
- Credentials
- Logs
- SQLite database (if using SQLite)

## Security

- Runs as non-root user (UID 1000)
- Uses security contexts for enhanced security
- Supports service account creation
- Credentials stored in Kubernetes secrets

## Upgrading

```bash
helm upgrade n8n-release .
```

## Uninstalling

```bash
helm uninstall n8n-release
```

**Note**: This will not delete the PersistentVolumeClaim. To delete it:
```bash
kubectl delete pvc -l app.kubernetes.io/name=n8n-helm
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/name=n8n-helm
```

### View Logs
```bash
kubectl logs -l app.kubernetes.io/name=n8n-helm
```

### Debug Configuration
```bash
helm template n8n-release . --debug
```

### Common Issues

1. **Pod stuck in Pending**: Check if PVC can be bound to a PV
2. **Database connection issues**: Verify database credentials and connectivity
3. **Webhook issues**: Ensure webhookUrl is accessible from external services

## Dependencies

- **PostgreSQL**: Optional dependency from Bitnami (version 16.7.21)

## Support

For n8n specific issues, refer to the [n8n documentation](https://docs.n8n.io/).
For chart issues, check the templates and values configuration.