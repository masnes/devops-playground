resource "aws_instance" "vault_server" {
  ami             = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type   = "t3a.nano"
  key_name        = aws_key_pair.t480_laptop.key_name
  security_groups = [aws_security_group.base.name]

  root_block_device {
    encrypted = true
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/masnes/.ssh/id_rsa")
  }

}

resource "aws_eip" "vault_ip" {
  instance = aws_instance.vault_server.id
}

resource "aws_route53_record" "vault_server" {
  zone_id = var.user_route53_hosted_zone
  name    = "vault-server.michaelasnes.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.vault_ip.public_ip]
}

output "vault_server" {
  value = aws_instance.vault_server.public_dns
}
