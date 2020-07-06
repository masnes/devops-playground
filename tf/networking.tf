resource "aws_vpc" "devops_playground" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.devops_playground.id
  cidr_block        = "172.16.0.0/17" # ends at 172.16.127.255
  availability_zone = "us-east-2"

  map_public_ip_on_launch = false # It's the default, but make explicit here
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.devops_playground.id
  cidr_block        = "172.16.128.0/24" # ends at 172.16.128.255
  availability_zone = "us-east-2"
}

resource "aws_eip" "public_nat_ip" {
  vpc = true
}

resource "aws_nat_gateway" "public_nat" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.public_nat_ip.id
}

resource "aws_route_table" "public_private_table" {
  vpc_id = aws_vpc.devops_playground

  # default route for vpc cidr to local is implicitly created

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat.id
  }
}
