# 5. ArgoCD — bootstrap

Установка ArgoCD и настройка GitOps через `homelab-gitops`.

| Переменная | Описание |
|------------|----------|
| `KUBECONFIG` | Путь к kubeconfig кластера |
| `HOMELAB_DOMAIN` | Домен (`itruslan.ru`) |

## k8s-argocd

```bash
cd terraform/kubernetes/k8s-argocd
tg apply
```

Получить пароль admin:

```bash
tg output -raw initial_admin_password
```

UI доступен на `https://argocd.itruslan.ru`.

## GitOps

ArgoCD управляет приложениями из `homelab-gitops`. Root Application создаётся через Terraform и указывает на `bootstrap/` в репо.

Порядок деплоя приложений управляется через `argocd.argoproj.io/sync-wave` аннотации в bootstrap манифестах.

## proxmox-csi

После деплоя proxmox-csi нужно создать секрет с API токеном вручную:

```bash
kubectl -n proxmox-csi-plugin create secret generic proxmox-csi-plugin \
  --from-literal=token-secret=${PROXMOX_VE_API_TOKEN##*=}
```

И проставить topology labels на нодах:

```bash
kubectl label node k8s-master-1 topology.kubernetes.io/region=homelab topology.kubernetes.io/zone=pve-1
kubectl label node k8s-master-2 topology.kubernetes.io/region=homelab topology.kubernetes.io/zone=pve-2
kubectl label node k8s-master-3 topology.kubernetes.io/region=homelab topology.kubernetes.io/zone=pve-3
kubectl label node k8s-worker-1 topology.kubernetes.io/region=homelab topology.kubernetes.io/zone=pve-1
kubectl label node k8s-worker-2 topology.kubernetes.io/region=homelab topology.kubernetes.io/zone=pve-2
kubectl label node k8s-worker-3 topology.kubernetes.io/region=homelab topology.kubernetes.io/zone=pve-3
```
