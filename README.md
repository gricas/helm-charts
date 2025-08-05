# Helm Charts Repository

This repository contains Helm charts for deploying applications to Kubernetes.

## Available Charts

- **cert-manager** - Certificate management for Kubernetes
- **ingress-nginx** - NGINX Ingress Controller
- **kube-prometheus-stack** - Prometheus monitoring stack
- **n8n** - Workflow automation platform

## CI/CD Pipeline

The repository uses GitHub Actions for continuous integration with the following workflow:

### Workflow Jobs

1. **Validate Charts** - Basic chart structure validation
2. **Lint and Test Charts** - Individual chart linting and template testing
3. **Chart Testing** - Advanced testing using chart-testing (ct) tool

### What Gets Tested

- ✅ Chart.yaml structure validation
- ✅ Helm chart linting
- ✅ Template rendering with default values
- ✅ Template rendering with custom values files
- ✅ Dependency management
- ✅ Chart-testing (ct) validation

### Trigger Conditions

The CI runs on:
- Push to `main` or `master` branches
- Pull requests to `main` or `master` branches
- Only when files in `helm/**` are modified

## Local Development

### Prerequisites

- Helm 3.14.0+
- chart-testing (ct) tool
- kubectl (for testing)

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd charts

# Install chart-testing
curl -L https://github.com/helm/chart-testing/releases/latest/download/ct_linux_amd64.tar.gz | tar xz
sudo mv ct /usr/local/bin/ct

# Add required Helm repositories
helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Testing Charts

```bash
# Test a specific chart
cd helm/cert-manager
helm lint .
helm template test-release . --debug --dry-run

# Test all charts with ct
ct lint --all --config .github/ct.yaml
ct install --all --config .github/ct.yaml
```

## Chart Structure

Each chart follows the standard Helm chart structure:

```
helm/chart-name/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/          # Kubernetes templates
├── charts/            # Dependencies (if any)
└── Chart.lock         # Locked dependencies
```

## Best Practices

### Chart Development

1. **Always validate locally** before pushing
2. **Update dependencies** when adding new ones
3. **Test with multiple values files** if they exist
4. **Follow Helm best practices** for chart structure

### CI/CD Best Practices

1. **Conditional execution** - Jobs only run when needed
2. **Clear error messages** - Easy to understand failures
3. **Matrix testing** - Test each chart individually
4. **Graceful failures** - Don't fail the entire pipeline for one chart

### Troubleshooting

#### Common Issues

1. **Chart.lock missing** - Run `helm dependency update`
2. **Template validation fails** - Check values files and templates
3. **Dependencies not found** - Verify Chart.yaml dependencies
4. **ct command not found** - Install chart-testing tool

#### Debug Commands

```bash
# Check chart structure
helm lint .

# Validate templates
helm template test-release . --debug --dry-run

# Check dependencies
helm dependency list
helm dependency update

# Test with ct
ct lint --config .github/ct.yaml
ct install --config .github/ct.yaml
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with the commands above
5. Push and create a pull request

The CI pipeline will automatically test your changes.

## Support

For issues and questions related to specific charts, please refer to the individual chart documentation in their respective directories.

For CI/CD issues, check the GitHub Actions logs and ensure all prerequisites are met.

