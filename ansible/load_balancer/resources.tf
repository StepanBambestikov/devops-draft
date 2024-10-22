data "digitalocean_ssh_key" "rebrain-key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_ssh_key" "my-key" {
  name = "Terraform Example my key"
#  public_key = var.my_ssh_key
  public_key = "${file("./id_rsa.pub")}"
}

resource "digitalocean_tag" "email_tag" {
  #name = var.email.tag
  name = "email:namestnikov_at_g_nsu_ru"
}

resource "digitalocean_tag" "task_tag" {
  #name = var.task_tag
  name = "task:ansible_1"
}

locals{
  droplet_ips = [for droplet in digitalocean_droplet.web : droplet.ipv4_address]
}

resource "digitalocean_droplet" "web" {
  count = var.droplet_count
  image = "ubuntu-20-04-x64"
  name = "web-1"
  #disk = "25"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.rebrain-key.fingerprint, digitalocean_ssh_key.my-key.fingerprint]
  tags = [digitalocean_tag.email_tag.id, digitalocean_tag.task_tag.id]
}

data "aws_route53_zone" "domain_zone"{
  name = var.input_domain_zone
}

resource "aws_route53_record" "domain"{
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  name = var.domain_name
  type = "A"
  ttl = var.ttl_number
  records = [local.droplet_ips[0]]
}

#resource "aws_route53_record" "domain2"{
#  zone_id = data.aws_route53_zone.domain_zone.zone_id
#  name = var.domain_name2
#  type = "A"
#  ttl = var.ttl_number
#  records = [digitalocean_droplet.web.ipv4_address]
#}


resource "local_file" "inventory"{
  filename = "${path.module}/inventory.yaml"
  content = "${templatefile("${path.root}/vms.tftpl", {droplet_ips = local.droplet_ips})}"
}

resource "local_file" "vars"{
  filename = "${path.module}/group_vars/vars.yml"
  content = "${templatefile("${path.root}/vars.tftpl", {origin_host = local.droplet_ips[1]})}"

#  provisioner "local-exec" {
#      command = "sleep 60s && ansible-playbook ansible_playbook.yaml -i inventory.yaml --private-key=./id_rsa --extra-vars 'group_vars/vars.yml'"
#  }
}

