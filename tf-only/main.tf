provider "ibm" {
}

resource "ibm_compute_ssh_key" "ssh_key_ecomm" {
    label = "ecomm-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtxAJ/eZ+kpXoMhH22ueF4z2X+wPLLJiUDHcDjCbLATvVItU1GPW6LIOsVTHAC5SKG+9bCBmA7yiBlzdNg3FokPxzubYNAogqtq7ogRbTkdR+3KLIxGBFuvHufbSdV8NldgF7ICoAVIH5rqI2AFTG9+1g+5m/tG9CBsogsJmIBU4qhXVDs+scdDxfcoysJ3liiv3PnFdIC7yDpJRNyUf0wxY1de/ZX+OK1vyF+f8ef0kLePk333aLF1kjgnG495U13giuMcsVlVIYFXqqEOWheAh69xcblaU22MWYCiVyDS3eFqHg1S85IM6ngY3tOVomML5+C9HvZvTgfKnCtUTGh mcolton@us.ibm.com"
}

resource "ibm_compute_vm_instance" "ecomm" {
  hostname = "ecomm1"
  domain = "mcltn-demo.cc"
  os_reference_code = "UBUNTU_16_64"
  datacenter = "dal13"
  network_speed = 100
  hourly_billing = true
  private_network_only = false
  cores = 1
  memory = 1024
  disks = [25]
  local_disk = false
  ssh_key_ids = [
    "${ibm_compute_ssh_key.ssh_key_ecomm.id}"
  ],

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx > /tmp/nginx.log",
      "service nginx start",
      "wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "sudo apt-get install -y apt-transport-https",
      "sudo apt-get update",
      "sudo apt-get install -y aspnetcore-runtime-2.2",
      "cd /var/www",
      "sudo mkdir SimplCommerce"
    ]
  },
  provisioner "file" {
    source = "../../SimplCommerce/src/SimplCommerce.WebHost/bin/Release/netcoreapp2.2/publish/"
    destination = "/var/www/SimplCommerce"
  },

  provisioner "file" {
    source = "nginx.conf"
    destination = "/etc/nginx/sites-available/default"
  },
  
  provisioner "remote-exec" {
    inline = [
      "service nginx stop",
      "service nginx start",
    ]
  },

  provisioner "file" {
    source = "dotnet.service"
    destination = "/etc/systemd/system/simplcommerce.service"
  },

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable simplcommerce.service",
      "sudo systemctl start simplcommerce.service",
    ]
  },
  
}
