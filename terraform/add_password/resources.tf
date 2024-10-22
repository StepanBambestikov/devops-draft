data "digitalocean_ssh_key" "rebrain_key" {
  name = var.rebrain_key_name
}

resource "digitalocean_ssh_key" "my_key" {
  name = var.my_key_name
  public_key = var.my_ssh_key
}

resource "digitalocean_tag" "email_tag" {
  name = var.email_tag
}

resource "digitalocean_tag" "module_tag" {
  name = var.module_tag
}

locals{
  droplet_ips = digitalocean_droplet.web[*].ipv4_address
  droplet_passwords = random_string.password[*].result
}

resource "random_string" "password"{
  count = var.droplet_count
  length = var.password_length
  lower = false
}

resource "digitalocean_droplet" "web" {
  count = var.droplet_count
  image = "ubuntu-20-04-x64"
  name = "web-1"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint, digitalocean_ssh_key.my_key.fingerprint]
  tags = [digitalocean_tag.email_tag.id, digitalocean_tag.module_tag.id]

  provisioner "remote-exec" {

    connection{
      host = digitalocean_droplet.web[count.index].ipv4_address
      type = "ssh"
      user = "root"
      private_key = var.my_private_key      
    }    

    inline = [
      "echo 'root:${local.droplet_passwords[count.index]}' | chpasswd",
      "sleep 60s",
      "echo 'ip: ${digitalocean_droplet.web[count.index].ipv4_address}, password: ${local.droplet_passwords[count.index]}'",
      "sed -i 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config",
      "sed -i 's/PasswordAuthentication .*/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sed -i 's/#PubkeyAuthentication .*/PubkeyAuthentication no/g' /etc/ssh/sshd_config",
      "systemctl restart sshd",
    ]
  }
}

data "aws_route53_zone" "domain_zone"{
  name = var.input_domain_zone
}

resource "aws_route53_record" "domain"{
  count = var.droplet_count
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  name = "${var.domain_prefix}-${count.index}.${var.domain_name}"
  type = "A"
  ttl = var.ttl_number
  records = [local.droplet_ips[count.index]]
}
