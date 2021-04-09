terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}
resource "libvirt_volume" "distro-qcow2" {
  count  = var.hostcount
  name   = "${var.hostnames[count.index]}.qcow2"
  pool   = var.poolname
  source = "${path.module}/sources/${var.distro}.qcow2"
  format = "qcow2"
}
resource "libvirt_cloudinit_disk" "commoninit" { 
  count     = var.hostcount
  name      = "commoninit-${var.hostnames[count.index]}.iso"
  pool      = var.poolname  
  user_data = templatefile("${path.module}/templates/user_data.tpl", {
      host_name = var.hostnames[count.index]
      auth_key  = file("${path.module}/ssh/id_rsa.pub")
  })
  network_config =   templatefile("${path.module}/templates/network_config.tpl", {
     interface = var.interface
     ip_addr   = var.ips[count.index]
     mac_addr = var.macs[count.index]
  })
}
resource "libvirt_domain" "domain-distro" {
  count  = var.hostcount
  name   = var.hostnames[count.index]
  memory = var.memory
  vcpu   = var.vcpu
  cloudinit = element(libvirt_cloudinit_disk.commoninit.*.id, count.index)
  
  network_interface {
      network_name = "default"
      addresses    = [var.ips[count.index]]
      mac          = var.macs[count.index]
  }
  console {
      type        = "pty"
      target_port = "0"
      target_type = "serial"
  }
  console {
      type        = "pty"
      target_port = "1"
      target_type = "virtio"
  }
  disk {
      volume_id = element(libvirt_volume.distro-qcow2.*.id, count.index)
  }
}