data "digitalocean_ssh_key" "rebrain-key" {
  name = var.rebrain_key_name
}

resource "digitalocean_ssh_key" "my-key" {
  name = var.my_key_name
  public_key = "${var.my_ssh_key}"
}

resource "digitalocean_tag" "email_tag" {
  name = var.email_tag
}

resource "digitalocean_tag" "task_tag" {
  name = var.task_tag
}

resource "digitalocean_droplet" "web" {
  image = "ubuntu-20-04-x64"
  name = "web-1"
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
