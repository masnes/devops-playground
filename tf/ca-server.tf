resource "aws_instance" "ca_server" {
  ami           = "ami-00f4b9641119301bf" # Debian 10 x86
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.user_provided_key.key_name

  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [
    aws_security_group.private_servers.id,
    aws_security_group.private_intraconnected.id
  ]

  root_block_device {
    encrypted = true
  }
}

resource "aws_route53_record" "ca_server" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "ca-server"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ca_server.private_ip]
}

output "ca_server" {
  value = aws_instance.ca_server.private_ip
}
