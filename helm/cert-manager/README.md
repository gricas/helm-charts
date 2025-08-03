# my cert-manager


## Installing the Chart

```sh
 kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml
```

```sh
helm dependency build
helm template mychart ./
```


## Advanced installation CD

https://cert-manager.io/docs/installation/continuous-deployment-and-gitops/

Using the Flux Helm Controller
The cert-manager Helm chart can be installed by the Flux Helm Controller.

## Upgrading 

https://cert-manager.io/docs/installation/upgrade/

## Uninstalling

```sh
helm delete cert-manager --namespace cert-manager
```

```sh
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml
```
