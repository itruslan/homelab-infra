# 4. Kubernetes — bootstrap

Установка кластера через kubespray (Docker образ).

## Требования

- Docker
- SSH доступ к нодам
- ВМ созданы через `proxmox-vm-k8s-masters` и `proxmox-vm-k8s-workers`

## Проверка доступности нод

```bash
cd kubespray
make ping
```

## Установка кластера

```bash
make install
```

Занимает ~20-30 минут.

## Получить kubeconfig

После установки на `k8s-master-1`:

```bash
ssh itruslan@192.168.99.201 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/homelab.yaml
export KUBECONFIG=~/.kube/homelab.yaml
kubectl get nodes
```

## Сброс кластера

```bash
make reset
```
