# grafana-observability

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.83.0](https://img.shields.io/badge/AppVersion-v0.83.0-informational?style=flat-square)

Custom Prometheus monitoring stack wrapper chart

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | 76.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kube-prometheus-stack.alertmanager.alertmanagerSpec.resources.limits.cpu | string | `"200m"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.resources.limits.memory | string | `"256Mi"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.resources.requests.cpu | string | `"50m"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.resources.requests.memory | string | `"128Mi"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage | string | `"10Gi"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName | string | `"local-path"` |  |
| kube-prometheus-stack.alertmanager.enabled | bool | `true` |  |
| kube-prometheus-stack.alertmanager.enabled | bool | `true` |  |
| kube-prometheus-stack.alertmanager.service.port | int | `9093` |  |
| kube-prometheus-stack.alertmanager.service.type | string | `"ClusterIP"` |  |
| kube-prometheus-stack.coreDns.enabled | bool | `true` |  |
| kube-prometheus-stack.grafana.admin.existingSecret | string | `"grafana-admin-secret"` |  |
| kube-prometheus-stack.grafana.admin.passwordKey | string | `"admin-password"` |  |
| kube-prometheus-stack.grafana.admin.userKey | string | `"admin-user"` |  |
| kube-prometheus-stack.grafana.enabled | bool | `true` |  |
| kube-prometheus-stack.grafana.enabled | bool | `true` |  |
| kube-prometheus-stack.grafana.ingress.enabled | bool | `false` |  |
| kube-prometheus-stack.grafana.livenessProbe.failureThreshold | int | `3` |  |
| kube-prometheus-stack.grafana.livenessProbe.httpGet.path | string | `"/api/health"` |  |
| kube-prometheus-stack.grafana.livenessProbe.httpGet.port | int | `3000` |  |
| kube-prometheus-stack.grafana.livenessProbe.initialDelaySeconds | int | `60` |  |
| kube-prometheus-stack.grafana.livenessProbe.periodSeconds | int | `30` |  |
| kube-prometheus-stack.grafana.livenessProbe.timeoutSeconds | int | `5` |  |
| kube-prometheus-stack.grafana.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| kube-prometheus-stack.grafana.persistence.enabled | bool | `true` |  |
| kube-prometheus-stack.grafana.persistence.size | string | `"10Gi"` |  |
| kube-prometheus-stack.grafana.persistence.storageClassName | string | `"local-path"` |  |
| kube-prometheus-stack.grafana.readinessProbe.failureThreshold | int | `3` |  |
| kube-prometheus-stack.grafana.readinessProbe.httpGet.path | string | `"/api/health"` |  |
| kube-prometheus-stack.grafana.readinessProbe.httpGet.port | int | `3000` |  |
| kube-prometheus-stack.grafana.readinessProbe.initialDelaySeconds | int | `30` |  |
| kube-prometheus-stack.grafana.readinessProbe.periodSeconds | int | `10` |  |
| kube-prometheus-stack.grafana.readinessProbe.timeoutSeconds | int | `5` |  |
| kube-prometheus-stack.grafana.resources.limits.cpu | string | `"1000m"` |  |
| kube-prometheus-stack.grafana.resources.limits.memory | string | `"1Gi"` |  |
| kube-prometheus-stack.grafana.resources.requests.cpu | string | `"100m"` |  |
| kube-prometheus-stack.grafana.resources.requests.memory | string | `"256Mi"` |  |
| kube-prometheus-stack.grafana.service.port | int | `80` |  |
| kube-prometheus-stack.grafana.service.type | string | `"ClusterIP"` |  |
| kube-prometheus-stack.kubeApiServer.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeControllerManager.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeEtcd.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeProxy.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeScheduler.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeStateMetrics.enabled | bool | `true` |  |
| kube-prometheus-stack.kubelet.enabled | bool | `true` |  |
| kube-prometheus-stack.namespaceOverride | string | `""` |  |
| kube-prometheus-stack.nodeExporter.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheus.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheus.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.cpu | string | `"2000m"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.memory | string | `"4Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.cpu | string | `"500m"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.memory | string | `"1Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage | string | `"50Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName | string | `"local-path"` |  |
| kube-prometheus-stack.prometheus.service.port | int | `9090` |  |
| kube-prometheus-stack.prometheus.service.type | string | `"ClusterIP"` |  |
| kube-prometheus-stack.prometheusOperator.enabled | bool | `true` |  |
