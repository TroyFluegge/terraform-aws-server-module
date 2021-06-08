terraform {
  required_version = ">= 0.12"
}

locals {
  name = replace(var.name, "^-?\\w+", "")
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["*CentOS 7.9.2009 x86_64*"]
  }
}

data "template_file" "config" {
  template = file("${path.module}/configs/${var.name}.tpl")
  vars = {
    upstream_ip = "${var.upstream_ip}"
  }
}

resource "aws_instance" "instance" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.centos.id
  vpc_security_group_ids      = [ var.security_group_id ]
  subnet_id                   = var.vpc_subnet_ids
  associate_public_ip_address = true
  key_name                    = var.public_key
  #iam_instance_profile        = aws_iam_instance_profile.instance.id
  private_ip                  = var.private_ip
  tags                        = var.tags

  user_data = data.template_file.config.rendered
}
