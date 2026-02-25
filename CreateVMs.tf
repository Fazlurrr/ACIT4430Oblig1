terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  cloud = "openstack"
}

# --------- Web Servers ---------
resource "openstack_compute_instance_v2" "webserver" {
  count       = 2
  name        = "webserver-${count.index + 1}"
  image_name  = "Ubuntu-24.04-LTS (Noble Numbat)"
  flavor_name = "aem.1c2r.50g"

  network { name = "oslomet" }

  key_pair        = "MasterVMKey"
  security_groups = ["default"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.access_ip_v4
  }
}

# --------- Load Balancer Server ---------
resource "openstack_compute_instance_v2" "loadbalancer" {
  count = 1
  name            = "loadbalancer-${count.index + 1}"
  image_name      = "Ubuntu-24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"

  network { name = "oslomet" }

  key_pair        = "MasterVMKey"
  security_groups = ["default"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.access_ip_v4
  }
}

# --------- Backup Server ---------
resource "openstack_compute_instance_v2" "backup" {
  count = 1
  name            = "backup-${count.index + 1}"
  image_name      = "Ubuntu-24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"

  network { name = "oslomet" }

  key_pair        = "MasterVMKey"
  security_groups = ["default"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.access_ip_v4
  }
}

# --------- Database Servers ---------
resource "openstack_compute_instance_v2" "database" {
  count       = 2
  name        = "database-${count.index + 1}"
  image_name  = "Ubuntu-24.04-LTS (Noble Numbat)"
  flavor_name = "aem.1c2r.50g"

  network { name = "oslomet" }

  key_pair        = "MasterVMKey"
  security_groups = ["default"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.access_ip_v4
  }
}

# --------- Outputs ---------
output "webserver_ips" {
  value = [for ws in openstack_compute_instance_v2.webserver : ws.access_ip_v4]
}

output "loadbalancer_ip" {
  value = [for ws in openstack_compute_instance_v2.loadbalancer : ws.access_ip_v4]
}

output "backup_ip" {
  value = [for ws in openstack_compute_instance_v2.backup : ws.access_ip_v4]
}

output "database_ips" {
  value = [for db in openstack_compute_instance_v2.database : db.access_ip_v4]
}
