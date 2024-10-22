data "digitalocean_ssh_key" "rebrain-key" {
  name = "REBRAIN.SSH.PUB.KEY"
  #public_key = "${var.rebrain_ssh_key}"
}

resource "digitalocean_ssh_key" "my-key" {
  name = "Terraform Example my key"
  public_key = "${var.my_ssh_key}"
}

resource "digitalocean_tag" "email_tag" {
  name = "user_email:s_namestnikov_at_g_nsu_ru"
}

resource "digitalocean_tag" "task_tag" {
  name = "task_name:terraform-02"
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
