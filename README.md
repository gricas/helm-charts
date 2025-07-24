# Helm Charts Repository

This repository contains Helm charts for deploying applications to Kubernetes.

## Available Charts

### n8n
A Helm chart for deploying n8n workflow automation platform to Kubernetes.

- **Chart Name**: n8n-helm
- **Version**: 0.1.0
- **App Version**: 0.1.0
- **Description**: Workflow automation platform with optional PostgreSQL database

## Quick Start

### Prerequisites
- Kubernetes cluster
- Helm 3.x installed
- kubectl configured to access your cluster

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd charts
   ```

2. Navigate to a chart directory:
   ```bash
   cd n8n
   ```

3. Install the chart:
   ```bash
   helm install my-release .
   ```

### Custom Configuration

Each chart includes a `values.yaml` file with default configuration. You can override these values by:

1. Creating a custom values file:
   ```bash
   helm install my-release . -f custom-values.yaml
   ```

2. Using --set flags:
   ```bash
   helm install my-release . --set service.type=LoadBalancer
   ```

## Chart Development

### Linting
```bash
helm lint <chart-directory>
```

### Testing
```bash
helm template my-release <chart-directory>
```

### Packaging
```bash
helm package <chart-directory>
```

## Contributing

1. Follow Helm chart best practices
2. Update chart version in Chart.yaml for any changes
3. Test charts thoroughly before submitting
4. Document any breaking changes

## Support

For issues and questions related to specific charts, please refer to the individual chart documentation in their respective directories.

