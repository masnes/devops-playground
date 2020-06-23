variable "user_default_vpc" {
  type = string
  default = "vpc-ef9d928a"
}

resource "aws_route53_zone" "private" {
  name = "devops-playground.com"

  vpc {
    vpc_id = var.user_default_vpc
  }
}

#variable "user_route53_hosted_zone" {
#  type    = string
#  default = "Z1TOKUY3VKZYQI" # *.michaelasnes.com.
#}

