KUBESPRAY_VERSION ?= v2.30.0
INVENTORY := inventory/homelab

.PHONY: install reset ping

install:
	docker run --rm -i \
		-v ~/.ssh/id_ed25519:/root/.ssh/id_ed25519:ro \
		-v $(PWD)/$(INVENTORY):/kubespray/inventory/homelab \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		ansible-playbook -i inventory/homelab/hosts.yaml cluster.yml

reset:
	docker run --rm -i \
		-v ~/.ssh/id_ed25519:/root/.ssh/id_ed25519:ro \
		-v $(PWD)/$(INVENTORY):/kubespray/inventory/homelab \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		ansible-playbook -i inventory/homelab/hosts.yaml reset.yml

ping:
	docker run --rm -i \
		-v ~/.ssh/id_ed25519:/root/.ssh/id_ed25519:ro \
		-v $(PWD)/$(INVENTORY):/kubespray/inventory/homelab \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		ansible -i inventory/homelab/hosts.yaml all -m ping
