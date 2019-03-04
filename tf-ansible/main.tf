
resource "ibm_compute_ssh_key" "ssh_key_ecomm" {
    label = "ecomm-key"
    public_key = "${var.ssh_public_key}"
}

# Create a private vlan East
resource "ibm_network_vlan" "lb_vlan_private_east" {
  name        = "${var.vlan_name_east}"
  datacenter  = "${var.datacenter_east}"
  type        = "PRIVATE"
}

# Create a private vlan South
resource "ibm_network_vlan" "lb_vlan_private_south" {
  name        = "${var.vlan_name_south}"
  datacenter  = "${var.datacenter_south}"
  type        = "PRIVATE"
}

resource "ibm_compute_vm_instance" "ecomm-east" {
    count = "${var.app_server_count}"
    hostname = "ecommeast-${count.index+1}"
    domain = "${var.domain}"
    os_reference_code = "${var.os_code}"
    datacenter = "${var.datacenter_east}"
    network_speed = 100
    hourly_billing = true
    private_network_only = false
    cores = 1
    memory = 1024
    disks = [25]
    local_disk = false
    private_vlan_id = "${ibm_network_vlan.lb_vlan_private_east.id}"
    ssh_key_ids = [
        "${ibm_compute_ssh_key.ssh_key_ecomm.id}"
    ],
}


resource "ibm_compute_vm_instance" "ecomm-south" {
    count = "${var.app_server_count}"
    hostname = "ecommsouth-${count.index+1}"
    domain = "${var.domain}"
    os_reference_code = "${var.os_code}"
    datacenter = "${var.datacenter_south}"
    network_speed = 100
    hourly_billing = true
    private_network_only = false
    cores = 1
    memory = 1024
    disks = [25]
    local_disk = false
    private_vlan_id = "${ibm_network_vlan.lb_vlan_private_south.id}"
    ssh_key_ids = [
        "${ibm_compute_ssh_key.ssh_key_ecomm.id}"
    ],
}

resource "null_resource" "run-playbook" {
    depends_on = [
        "ibm_compute_vm_instance.ecomm-east",
        "ibm_compute_vm_instance.ecomm-south"
        ]
    triggers {
        always_run = "${timestamp()}"
    }
    provisioner "local-exec" {
        command = "sleep 30; ansible-playbook -i /usr/local/bin/terraform-inventory main.yml"
    }
}

resource "ibm_lbaas" "lbaas_east" {
  name        = "lbaas2-east"
  description = ""
  subnets     = ["${ibm_compute_vm_instance.ecomm-east.0.private_subnet_id}"]
  protocols = [
    {
      frontend_protocol     = "HTTP"
      frontend_port         = 80
      backend_protocol      = "HTTP"
      backend_port          = 80
      load_balancing_method = "round_robin"
    },
  ]
}

resource "ibm_lbaas" "lbaas_south" {
  name        = "lbaas2-south"
  description = ""
  subnets     = ["${ibm_compute_vm_instance.ecomm-south.0.private_subnet_id}"]
  protocols = [
    {
      frontend_protocol     = "HTTP"
      frontend_port         = 80
      backend_protocol      = "HTTP"
      backend_port          = 80
      load_balancing_method = "round_robin"
    },
  ]
}

resource "ibm_lbaas_server_instance_attachment" "server_attach_east" {
    count = "${var.app_server_count}"
    private_ip_address = "${element(ibm_compute_vm_instance.ecomm-east.*.ipv4_address_private,count.index)}"
    lbaas_id = "${ibm_lbaas.lbaas_east.id}"
    depends_on = ["ibm_lbaas.lbaas_east"]
}

resource "ibm_lbaas_server_instance_attachment" "server_attach_south" {
    count = "${var.app_server_count}"
    private_ip_address = "${element(ibm_compute_vm_instance.ecomm-south.*.ipv4_address_private,count.index)}"
    lbaas_id = "${ibm_lbaas.lbaas_south.id}"
    depends_on = ["ibm_lbaas.lbaas_south"]
}