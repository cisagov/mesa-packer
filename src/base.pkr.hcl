packer {
  required_version = ">= 1.8.6"
  required_plugins {
    vmware = {
      version = ">= 1.0.10"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "vm_user_fullname" {
  type          = string
  description   = "Full name of VM user"
  default       = "Mesa User"
}

variable "vm_username" {
  type          = string
  description   = "Username for VM user"
  default       = "mesa"
}

variable "vm_password" {
  type          = string
  description   = "Password for VM user"
  sensitive     = true
  default       = "mesa"
}

variable "vm_hostname" {
  type          = string
  description   = "Hostname of VM"
  default       = "base-deb"
}

variable "vm_domain" {
  type          = string
  description   = "Domain for VM"
  default       = "mesa.local"
}

variable "http_bind_address" {
  type        = string
  description = "HTTP bind address"
  default    = "0.0.0.0"
}

variable "preseed_file" {
  type        = string
  description = "Preseed file to be used (must be in src/http/)"
  default     = "preseed.pkrtpl.hcl"
}

variable "output_directory" {
  type        = string
  description = "Output directory for Packer"
  default     = "${ env("HOME") }/Virtual Machines.localized/base-deb"
}

source "vmware-iso" "base-deb" {
  iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso"
  iso_checksum = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  shutdown_command = "echo '${var.vm_password}' | sudo -S shutdown -P now"
  output_directory = "${var.output_directory}"

  # VM Configurations
  vm_name               = "${var.vm_hostname}"
  headless              = false
  tools_upload_flavor   = "linux"
  shutdown_timeout      = "10m"
  snapshot_name         = "Base - ${formatdate("YYYY-MM-DD hh:mm", timestamp())}"

  # VM Connection
  ssh_username          = "${var.vm_username}"
  ssh_password          = "${var.vm_password}"
  ssh_timeout           = "8000s"
  guest_os_type         = "debian10-64" # Debian breaks vm customization for terraform

# VM Hardware Configuration
  disk_size             = "80000"
  cpus                  = 2
  memory                = 8192
  vmx_data = {
    "mks.enable3d" = "TRUE"
    "mks.disableWorkloadBasedGPUSwitching" = "TRUE"
  }

  # Preseed Configuration
  http_bind_address     = "0.0.0.0"
  http_content          = {
    "/preseed.cfg" = templatefile("${path.root}/../http/${var.preseed_file}", {
      fullname                  = "${var.vm_user_fullname}"
      username                  = "${var.vm_username}"
      password                  = "${var.vm_password}"
      hostname                  = "${var.vm_hostname}"
      domain                    = "${var.vm_domain}"
    })
  }

  # Boot Commands
  boot_wait = "10s"
  boot_command          = [
    "<esc><wait>",
    "/install.amd/vmlinuz<wait>",
    " initrd=/install.amd/gtk/initrd.gz<wait>",
    " auto-install/enable=true<wait>",
    " debconf/priority=critical<wait>",
    " netcfg/choose_interface=auto<wait>",
    " netcfg/dhcp_timeout=60<wait>",
    " netcfg/get_domain=${var.vm_domain}<wait>",
    " netcfg/get_hostname=${var.vm_hostname}<wait>",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
    " desktop=xfce<wait> vga=788<wait>",
    " -- <wait>",
    "<enter><wait>"
  ]
}

build {
  name = "base-deb"
  sources = ["source.vmware-iso.base-deb"]
}
