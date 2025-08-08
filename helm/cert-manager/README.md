# cert-manager

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.18.2](https://img.shields.io/badge/AppVersion-1.18.2-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager | 1.18.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert-manager.namespace | string | `"cert-manager"` |  |
| cert-manager.prometheus.enabled | bool | `true` |  |
| cert-manager.prometheus.podmonitor.enabled | bool | `true` |  |
| clusterIssuers.email | string | `""` |  |
| clusterIssuers.production.enabled | bool | `true` |  |
| clusterIssuers.production.name | string | `"letsencrypt-prod"` |  |
| clusterIssuers.production.server | string | `"https://acme-v02.api.letsencrypt.org/directory"` |  |
| clusterIssuers.route53.accessKeyID | string | `""` |  |
| clusterIssuers.route53.hostedZoneID | string | `""` |  |
| clusterIssuers.route53.region | string | `"us-east-1"` |  |
| clusterIssuers.route53.roleArn | string | `""` |  |
| clusterIssuers.secretRef.name | string | `"route53-credentials"` |  |
| clusterIssuers.secretRef.secretKey | string | `"secret-access-key"` |  |
| clusterIssuers.staging.enabled | bool | `true` |  |
| clusterIssuers.staging.name | string | `"letsencrypt-staging"` |  |
| clusterIssuers.staging.server | string | `"https://acme-staging-v02.api.letsencrypt.org/directory"` |  |
