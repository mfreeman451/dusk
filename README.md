# dusk

![DUSK Network](assets/dusk.png?raw=true "DUSK Network")

## K8s

Check the [k8s](./k8s) directory for Kubernetes deployment configurations.

## Staking DUSK node once deployed

```shell
kubectl exec -it deployment/dusk-node -- rusk-wallet stake --amt 1000
```