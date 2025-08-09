# ingress-nginx

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.13.0](https://img.shields.io/badge/AppVersion-1.13.0-informational?style=flat-square)

Wrapper chart for ingress-nginx controller with custom configurations and best practices

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | 4.13.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imageRegistry | string | `"registry.k8s.io"` |  |
| ingress-nginx.controller.admissionWebhooks.certManager.admissionCert.duration | string | `"8760h"` |  |
| ingress-nginx.controller.admissionWebhooks.certManager.enabled | bool | `false` |  |
| ingress-nginx.controller.admissionWebhooks.certManager.rootCert.duration | string | `"8760h"` |  |
| ingress-nginx.controller.admissionWebhooks.enabled | bool | `true` |  |
| ingress-nginx.controller.admissionWebhooks.failurePolicy | string | `"Fail"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.enabled | bool | `true` |  |
| ingress-nginx.controller.admissionWebhooks.patch.image.image | string | `"ingress-nginx/kube-webhook-certgen"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.image.pullPolicy | string | `"IfNotPresent"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.image.registry | string | `"registry.k8s.io"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.image.tag | string | `"v1.4.4"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.resources.limits.cpu | string | `"100m"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.resources.limits.memory | string | `"128Mi"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.resources.requests.cpu | string | `"10m"` |  |
| ingress-nginx.controller.admissionWebhooks.patch.resources.requests.memory | string | `"32Mi"` |  |
| ingress-nginx.controller.admissionWebhooks.timeoutSeconds | int | `10` |  |
| ingress-nginx.controller.affinity | object | `{}` |  |
| ingress-nginx.controller.autoscaling.enabled | bool | `false` |  |
| ingress-nginx.controller.autoscaling.maxReplicas | int | `3` |  |
| ingress-nginx.controller.autoscaling.minReplicas | int | `1` |  |
| ingress-nginx.controller.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| ingress-nginx.controller.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| ingress-nginx.controller.config.client-body-buffer-size | string | `"16k"` |  |
| ingress-nginx.controller.config.client-body-timeout | string | `"60"` |  |
| ingress-nginx.controller.config.client-header-timeout | string | `"60"` |  |
| ingress-nginx.controller.config.compute-full-forwarded-for | string | `"true"` |  |
| ingress-nginx.controller.config.enable-real-ip | string | `"true"` |  |
| ingress-nginx.controller.config.forwarded-for-header | string | `"X-Forwarded-For"` |  |
| ingress-nginx.controller.config.log-format-escape-json | string | `"true"` |  |
| ingress-nginx.controller.config.max-worker-connections | string | `"16384"` |  |
| ingress-nginx.controller.config.server-tokens | string | `"false"` |  |
| ingress-nginx.controller.config.ssl-ciphers | string | `"ECDHE-ECDSA-AES128-GCM-SHA256,ECDHE-RSA-AES128-GCM-SHA256,ECDHE-ECDSA-AES256-GCM-SHA384,ECDHE-RSA-AES256-GCM-SHA384"` |  |
| ingress-nginx.controller.config.ssl-protocols | string | `"TLSv1.2 TLSv1.3"` |  |
| ingress-nginx.controller.config.use-forwarded-headers | string | `"true"` |  |
| ingress-nginx.controller.config.worker-connections | string | `"16384"` |  |
| ingress-nginx.controller.config.worker-processes | string | `"auto"` |  |
| ingress-nginx.controller.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| ingress-nginx.controller.containerSecurityContext.capabilities.add[0] | string | `"NET_BIND_SERVICE"` |  |
| ingress-nginx.controller.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| ingress-nginx.controller.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| ingress-nginx.controller.containerSecurityContext.runAsGroup | int | `82` |  |
| ingress-nginx.controller.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| ingress-nginx.controller.containerSecurityContext.runAsUser | int | `101` |  |
| ingress-nginx.controller.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| ingress-nginx.controller.image.digest | string | `"sha256:dc75a7baec7a3b827a5d7ab0acd10ab507904c7dad692365b3e3b596eca1afd2"` |  |
| ingress-nginx.controller.image.image | string | `"ingress-nginx/controller"` |  |
| ingress-nginx.controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| ingress-nginx.controller.image.registry | string | `"registry.k8s.io"` |  |
| ingress-nginx.controller.image.tag | string | `"v1.13.0"` |  |
| ingress-nginx.controller.ingressClassResource.controllerValue | string | `"k8s.io/ingress-nginx"` |  |
| ingress-nginx.controller.ingressClassResource.default | bool | `true` |  |
| ingress-nginx.controller.ingressClassResource.enabled | bool | `true` |  |
| ingress-nginx.controller.ingressClassResource.name | string | `"nginx"` |  |
| ingress-nginx.controller.metrics.enabled | bool | `true` |  |
| ingress-nginx.controller.metrics.serviceMonitor.enabled | bool | `true` |  |
| ingress-nginx.controller.metrics.serviceMonitor.interval | string | `"30s"` |  |
| ingress-nginx.controller.metrics.serviceMonitor.scrapeTimeout | string | `"30s"` |  |
| ingress-nginx.controller.name | string | `"controller"` |  |
| ingress-nginx.controller.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| ingress-nginx.controller.podAnnotations | object | `{}` |  |
| ingress-nginx.controller.podDisruptionBudget.enabled | bool | `false` |  |
| ingress-nginx.controller.podDisruptionBudget.minAvailable | int | `1` |  |
| ingress-nginx.controller.podLabels | object | `{}` |  |
| ingress-nginx.controller.replicaCount | int | `1` |  |
| ingress-nginx.controller.resources.limits.cpu | string | `"500m"` |  |
| ingress-nginx.controller.resources.limits.memory | string | `"512Mi"` |  |
| ingress-nginx.controller.resources.requests.cpu | string | `"100m"` |  |
| ingress-nginx.controller.resources.requests.memory | string | `"256Mi"` |  |
| ingress-nginx.controller.service.type | string | `"LoadBalancer"` |  |
| ingress-nginx.controller.tolerations | list | `[]` |  |
| ingress-nginx.defaultBackend.enabled | bool | `false` |  |
| ingress-nginx.defaultBackend.image.image | string | `"defaultbackend-amd64"` |  |
| ingress-nginx.defaultBackend.image.registry | string | `"registry.k8s.io"` |  |
| ingress-nginx.defaultBackend.image.tag | string | `"1.5"` |  |
| ingress-nginx.defaultBackend.name | string | `"defaultbackend"` |  |
| ingress-nginx.defaultBackend.resources.limits.cpu | string | `"10m"` |  |
| ingress-nginx.defaultBackend.resources.limits.memory | string | `"20Mi"` |  |
| ingress-nginx.defaultBackend.resources.requests.cpu | string | `"10m"` |  |
| ingress-nginx.defaultBackend.resources.requests.memory | string | `"20Mi"` |  |
| ingress-nginx.defaultBackend.service.type | string | `"ClusterIP"` |  |
| ingress-nginx.enabled | bool | `true` |  |
| ingress-nginx.namespaceOverride | string | `""` |  |
| monitoring.enabled | bool | `true` |  |
| monitoring.prometheusRule.enabled | bool | `false` |  |
| monitoring.prometheusRule.labels | object | `{}` |  |
| monitoring.prometheusRule.namespace | string | `""` |  |
| monitoring.prometheusRule.rules[0].alert | string | `"IngressNginxControllerDown"` |  |
| monitoring.prometheusRule.rules[0].annotations.description | string | `"The Ingress NGINX Controller has been down for more than 5 minutes."` |  |
| monitoring.prometheusRule.rules[0].annotations.summary | string | `"Ingress NGINX Controller is down"` |  |
| monitoring.prometheusRule.rules[0].expr | string | `"up{job=\"ingress-nginx-controller-metrics\"} == 0"` |  |
| monitoring.prometheusRule.rules[0].for | string | `"5m"` |  |
| monitoring.prometheusRule.rules[0].labels.severity | string | `"critical"` |  |
| monitoring.prometheusRule.rules[1].alert | string | `"IngressNginxHighErrorRate"` |  |
| monitoring.prometheusRule.rules[1].annotations.description | string | `"Error rate is above 5% for the last 5 minutes."` |  |
| monitoring.prometheusRule.rules[1].annotations.summary | string | `"High error rate in Ingress NGINX"` |  |
| monitoring.prometheusRule.rules[1].expr | string | `"(\n  sum(rate(nginx_ingress_controller_requests{status=~\"5..\"}[5m]))\n  /\n  sum(rate(nginx_ingress_controller_requests[5m]))\n) * 100 > 5\n"` |  |
| monitoring.prometheusRule.rules[1].for | string | `"5m"` |  |
| monitoring.prometheusRule.rules[1].labels.severity | string | `"warning"` |  |
| monitoring.serviceMonitor.enabled | bool | `true` |  |
| monitoring.serviceMonitor.interval | string | `"30s"` |  |
| monitoring.serviceMonitor.labels | object | `{}` |  |
| monitoring.serviceMonitor.namespace | string | `""` |  |
| monitoring.serviceMonitor.scrapeTimeout | string | `"30s"` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress[0].from | list | `[]` |  |
| networkPolicy.ingress[0].ports[0].port | int | `80` |  |
| networkPolicy.ingress[0].ports[0].protocol | string | `"TCP"` |  |
| networkPolicy.ingress[0].ports[1].port | int | `443` |  |
| networkPolicy.ingress[0].ports[1].protocol | string | `"TCP"` |  |
| networkPolicy.ingress[0].ports[2].port | int | `8080` |  |
| networkPolicy.ingress[0].ports[2].protocol | string | `"TCP"` |  |
| networkPolicy.ingress[0].ports[3].port | int | `8443` |  |
| networkPolicy.ingress[0].ports[3].protocol | string | `"TCP"` |  |
