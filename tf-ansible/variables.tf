variable "ssh_public_key" {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtxAJ/eZ+kpXoMhH22ueF4z2X+wPLLJiUDHcDjCbLATvVItU1GPW6LIOsVTHAC5SKG+9bCBmA7yiBlzdNg3FokPxzubYNAogqtq7ogRbTkdR+3KLIxGBFuvHufbSdV8NldgF7ICoAVIH5rqI2AFTG9+1g+5m/tG9CBsogsJmIBU4qhXVDs+scdDxfcoysJ3liiv3PnFdIC7yDpJRNyUf0wxY1de/ZX+OK1vyF+f8ef0kLePk333aLF1kjgnG495U13giuMcsVlVIYFXqqEOWheAh69xcblaU22MWYCiVyDS3eFqHg1S85IM6ngY3tOVomML5+C9HvZvTgfKnCtUTGh mcolton@us.ibm.com"
}

variable "app_server_count" {
  default = 2
}

variable "hostname" {
  default = "app"
}

variable "os_code" {
    default = "UBUNTU_16_64"
}

variable "datacenter_east" {
  default = "wdc07"
}

variable "datacenter_south" {
  default = "dal13"
}

variable "datacenter_west" {
  default = "sjc04"
}

variable "vlan_name_east" {
  default = "ecomm_vlan_east"
}

variable "vlan_name_south" {
  default = "ecomm_vlan_south"
}

variable "cis_instance" {
  default = "cis-mcltn-1"
}

variable "domain" {
  default = "mcltn-demo.com"
}

variable "domain_id" {
    default = "1e9b0acfaf016c98178b4e6b0246a47a"
}

variable "dns_name" {
  default = "ecommdemo"
}

variable "resource_group" {
  default = "default"
}