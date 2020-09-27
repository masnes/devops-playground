resource "aws_instance" "vault_server" {
  ami           = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.t480_laptop.key_name

  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [
    aws_security_group.private_servers.id,
    aws_security_group.private_intraconnected.id
  ]

  root_block_device {
    encrypted = true
  }

}

resource "aws_route53_record" "vault_server" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "vault-server.devops-playground.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.vault_server.private_ip]
}

output "vault_server" {
  value = aws_instance.vault_server.private_ip
}
