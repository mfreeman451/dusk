# dusk network k8s - kustomize base

## Namespace

Create a 'dusk' namespace first

```shell
kubectl create namespace dusk
```

## Secrets

This may or may not appear in the repository as a file, so it is documented here.

### Declarative

```yaml
# Secret for storing sensitive DUSK node data
apiVersion: v1
kind: Secret
metadata:
  name: dusk-node-secret
type: Opaque
data:
  # Base64 encoded values - replace these with actual values
  mnemonic: "" # Your DUSK wallet mnemonic
  wallet-password: "" # Password for the wallet
  consensus-password: "" # Password for consensus keys

```

or

### Imperative

```shell
# Create these files first with your actual values
echo -n "your-mnemonic" > mnemonic
echo -n "your-wallet-password" > wallet-password  
echo -n "your-consensus-password" > consensus-password

# Create the secret
kubectl create secret generic dusk-node-secret \
  --from-file=mnemonic \
  --from-file=wallet-password \
  --from-file=consensus-password
```

## Applying manifests using Kustomize

```shell
cd k8s/
kubectl apply -k base/
```