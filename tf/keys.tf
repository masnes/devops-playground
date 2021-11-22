variable "authorized_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

data "local_file" "provided_public_key" {
  filename = pathexpand(var.authorized_key_path)
}

resource "aws_key_pair" "user_provided_key" {
  key_name   = "user_provided_key"
  public_key = data.local_file.provided_public_key.content
}
