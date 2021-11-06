terraform {
  required_version = "~> 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_ssh_key" "my" {
  name       = "My ssh_keys"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "www-lnx01" {
  image     = "ubuntu-20-04-x64"
  name      = "www-lnx01"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  tags      = ["nginx", "dmikulich_at_mail_ru", "linux"]
  private_networking = true
  #user_data = file("terramino_app.yaml")
  ssh_keys  = [digitalocean_ssh_key.my.fingerprint]
}

output "ip_address" {
  value = digitalocean_droplet.www-lnx01.ipv4_address
  description = "The public IP address of your Droplet application."
}