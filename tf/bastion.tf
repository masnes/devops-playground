resource "aws_instance" "bastion" {
  ami           = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.t480_laptop.key_name
  security_groups = [
    aws_security_group.base.name,
    aws_security_group.intraconnected.name
  ]

  subnet_id = aws_subnet.public.id

  root_block_device {
    encrypted = true
  }
}

resource "aws_eip" "bastion_ip" {
  instance = aws_instance.bastion.id
}

resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bastion.devops-playground.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion_ip.private_ip]
}

output "bastion" {
  value = aws_instance.bastion.public_dns
}
