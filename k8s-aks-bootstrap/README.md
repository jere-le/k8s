# AKS + kube-prometheus-stack bootstrap

Tämä paketti tekee Techno Timin Prometheus/Grafana-idean AKS:lle.

Mukana:
- AKS-klusterin luonti Azure CLI:llä
- AKS application routing add-on (managed NGINX ingress)
- kube-prometheus-stack Helmillä
- Grafana- ja Prometheus-ingressit
- pieni demo-appi testaukseen

## 1. Prereqs

Tarvitset:
- Azure CLI
- kubectl
- kubelogin
- Helm 3
- Azure-tilaus, johon saat luoda AKS:n

Voit asentaa työkalut näin:

```bash
chmod +x scripts/*.sh
./scripts/00-install-prereqs.sh
```

## 2. Muokkaa asetukset

```bash
cp .env.example .env
nano .env
```

Vaihda vähintään:
- `AZ_RESOURCE_GROUP`
- `AKS_NAME`
- `GRAFANA_HOST`
- `PROMETHEUS_HOST`
- `GRAFANA_ADMIN_PASSWORD`

## 3. Luo AKS

```bash
./scripts/10-create-aks.sh
```

## 4. Hae kubeconfig

```bash
./scripts/20-connect.sh
kubectl get nodes
```

## 5. Asenna monitoring stack

```bash
./scripts/30-install-monitoring.sh
```

## 6. Tarkista että kaikki tuli ylös

```bash
kubectl get pods -n monitoring
kubectl get ingress -n monitoring
kubectl get svc -n app-routing-system
```

## 7. Lisää DNS

Pointtaa nämä AKS ingressin public IP:hen:
- `GRAFANA_HOST`
- `PROMETHEUS_HOST`

Public IP löytyy näin:

```bash
kubectl get svc -n app-routing-system
```

## 8. Login Grafanaan

Käyttäjä:

```text
admin
```

Salasana:

```text
arvo .env tiedostosta: GRAFANA_ADMIN_PASSWORD
```

## 9. Demo-appi

```bash
kubectl apply -f apps/demo/
kubectl get all -n demo
```

## 10. Poisto

```bash
az group delete --name "$AZ_RESOURCE_GROUP" --yes --no-wait
```

## Huomio

Tässä setissä Grafana ja Prometheus ovat persistentillä levyllä, jotta data ei häviä podin uudelleenkäynnistyksessä.
