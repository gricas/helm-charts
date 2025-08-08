# Helm Charts Repository

This repository contains Helm charts for deploying applications to Kubernetes.

## 📊 CI/CD Status

[![CI](https://github.com/gricas/charts/actions/workflows/ci.yml/badge.svg)](https://github.com/gricas/charts/actions/workflows/ci.yml)

## Available Charts

- **cert-manager** - Certificate management for Kubernetes
- **ingress-nginx** - NGINX Ingress Controller
- **kube-prometheus-stack** - Prometheus monitoring stack
- **n8n** - Workflow automation platform

## CI/CD Pipeline

The repository uses GitHub Actions for continuous integration with reusable workflows:

### Reusable Workflows

1. **Setup Environment** (`.github/workflows/setup-environment.yml`)
   - Installs Helm and chart-testing tools
   - Adds required Helm repositories
   - Configurable parameters for version, tools, and git fetch depth

2. **Validate Chart** (`.github/workflows/validate-chart.yml`)
   - Validates individual charts
   - Performs linting and template testing
   - Handles dependencies and custom values files

3. **Test Charts with CT** (`.github/workflows/test-charts-ct.yml`)
   - Advanced testing using chart-testing (ct) tool
   - Supports lint, install, or both test types
   - Configurable via ct.yaml

### Main CI Workflow Jobs

1. **Setup** - Sets up the environment using reusable workflow
2. **Validate Charts** - Basic chart structure validation
3. **Lint and Test Charts** - Individual chart validation using reusable workflow
4. **Chart Testing** - Advanced testing using reusable workflow

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
CT_VERSION=$(curl -s https://api.github.com/repos/helm/chart-testing/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Installing chart-testing version: $CT_VERSION"
CT_VERSION_NUM=$(echo "$CT_VERSION" | sed 's/^v//')
echo "Version number: $CT_VERSION_NUM"
curl -L "https://github.com/helm/chart-testing/releases/download/${CT_VERSION}/chart-testing_${CT_VERSION_NUM}_linux_amd64.tar.gz" | tar xz
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

1. **Reusable workflows** - Common tasks are modularized
2. **Conditional execution** - Jobs only run when needed
3. **Clear error messages** - Easy to understand failures
4. **Matrix testing** - Test each chart individually
5. **Graceful failures** - Don't fail the entire pipeline for one chart
6. **DRY principle** - No code duplication across workflows

### Using Reusable Workflows

You can call these workflows from other repositories or workflows:

```yaml
jobs:
  setup:
    uses: ./.github/workflows/setup-environment.yml
    with:
      helm-version: '3.14.0'
      install-ct: true

  validate:
    uses: ./.github/workflows/validate-chart.yml
    with:
      chart-name: my-chart
      chart-path: helm/my-chart

  test:
    uses: ./.github/workflows/test-charts-ct.yml
    with:
      config-file: .github/ct.yaml
      test-type: both
```

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
