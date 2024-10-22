data "digitalocean_ssh_key" "rebrain-key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_ssh_key" "my-key" {
  name = "Terraform Example my key"
  public_key = var.my_ssh_key
}

resource "digitalocean_tag" "email_tag" {
  name = var.email.tag
}

resource "digitalocean_tag" "task_tag" {
  name = var.task_tag
}

resource "digitalocean_droplet" "web" {
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
  records = [digitalocean_droplet.web.ipv4_address]
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
  content = "${templatefile("${path.root}/vms.tftpl", {ip = digitalocean_droplet.web.ipv4_address})}"
}
