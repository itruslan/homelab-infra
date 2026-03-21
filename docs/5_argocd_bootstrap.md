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
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

UI доступен на `https://argocd.itruslan.ru`.

## bootstrap GitOps

```bash
kubectl apply -f /Users/rgadzhiev/GitHub/homelab-gitops/apps/argocd/templates/appproject-infra.yaml
kubectl apply -f /Users/rgadzhiev/GitHub/homelab-gitops/bootstrap/argocd.yaml
```

После этого ArgoCD управляет собой из `homelab-gitops`.
