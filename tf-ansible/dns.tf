data "ibm_cis" "app_domain" {
  name = "${var.cis_instance}"
}

resource "ibm_cis_healthcheck" "root" {
  cis_id         = "${data.ibm_cis.app_domain.id}"
  description    = "Websiteroot"
  expected_body  = ""
  expected_codes = "200"
  path           = "/"
}

resource "ibm_cis_origin_pool" "wdc" {
  cis_id        = "${data.ibm_cis.app_domain.id}"
  name          = "${var.datacenter_east}"
  check_regions = ["WNAM"]
  monitor = "${ibm_cis_healthcheck.root.id}"
  origins = [{
    name    = "${var.datacenter_east}"
    address = "${ibm_lbaas.lbaas_east.vip}"
    enabled = true
  }]
  description = "WDC pool"
  enabled     = true
}

resource "ibm_cis_origin_pool" "dal" {
  cis_id        = "${data.ibm_cis.app_domain.id}"
  name          = "${var.datacenter_south}"
  check_regions = ["WNAM"]
  monitor = "${ibm_cis_healthcheck.root.id}"
  origins = [{
    name    = "${var.datacenter_south}"
    address = "${ibm_lbaas.lbaas_south.vip}"
    enabled = true
  }]
  description = "DAL pool"
  enabled     = true
}

resource "ibm_cis_global_load_balancer" "glb" {
  cis_id           = "${data.ibm_cis.app_domain.id}"
  domain_id        = "${var.domain_id}:${data.ibm_cis.app_domain.id}"
  name             = "${var.dns_name}.${var.domain}"
  fallback_pool_id = "${ibm_cis_origin_pool.wdc.id}"
  default_pool_ids = ["${ibm_cis_origin_pool.dal.id}", "${ibm_cis_origin_pool.wdc.id}"]
  description      = "Global Load Balancer"
  proxied          = true
  session_affinity = "cookie"
}