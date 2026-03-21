# 4. Kubernetes — bootstrap

Установка кластера через kubespray. ВМ должны быть созданы заранее.

| Переменная | Описание |
|------------|----------|
| `VM_USERNAME` | Пользователь на нодах |
| `TF_VAR_ssh_public_key` | SSH публичный ключ для доступа к нодам |
| `KUBECONFIG` | Путь к kubeconfig после установки |

```bash
cd kubespray
make ping     # проверить доступность нод
make install  # ~30 минут
```

Получить kubeconfig:

```bash
ssh itruslan@192.168.99.201 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/homelab.yaml
export KUBECONFIG=~/.kube/homelab.yaml
kubectl get nodes
```

Сброс: `make reset`
