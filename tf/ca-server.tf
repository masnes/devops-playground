resource "aws_instance" "ca_server" {
  ami             = "ami-00f4b9641119301bf" # Debian 10 x86
  instance_type   = "t3a.nano"
  key_name        = aws_key_pair.t480_laptop.key_name
  security_groups = [aws_security_group.base.name]

  root_block_device {
    encrypted = true
  }

  connection {
    type        = "ssh"
    user        = "admin"
    host        = self.public_ip
    private_key = file("/home/masnes/.ssh/id_rsa")
  }
}

resource "aws_eip" "ca_ip" {
  instance = aws_instance.ca_server.id
}

resource "aws_route53_record" "ca_server" {
  zone_id = var.user_route53_hosted_zone
  name    = "ca-server.michaelasnes.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.ca_ip.public_ip]
}

output "ca_server" {
  value = aws_instance.ca_server.public_dns
}
