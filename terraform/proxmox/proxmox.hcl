locals {
  modules_local    = get_env("MODULES_LOCAL_PATH", "")
  proxmox_endpoint = get_env("PROXMOX_VE_ENDPOINT")

  clone = {
    vm_id     = 90001
    node_name = "pve-1"
  }

  initialization = {
    username     = get_env("VM_USERNAME")
    ssh_keys     = [get_env("TF_VAR_ssh_public_key")]
    ipv4_gateway = get_env("DEFAULT_GATEWAY")
    dns_servers  = split(",", get_env("DNS_SERVERS"))
    dns_domain   = get_env("DNS_DOMAIN")
  }
}
