# Switching to custom vpc
#variable "user_default_vpc" {
#  type    = string
#  default = "vpc-ef9d928a"
#}

resource "aws_route53_zone" "private" {
  name = "devops-playground.io"

  vpc {
    vpc_id = aws_vpc.devops_playground.id
  }
}

#variable "user_route53_hosted_zone" {
#  type    = string
#  default = "Z1TOKUY3VKZYQI" # *.michaelasnes.com.
#}

