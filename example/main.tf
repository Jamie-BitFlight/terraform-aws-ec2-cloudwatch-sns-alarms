module "alarms" {
  source       = "../"
  context      = "${module.label.context}"
  instance_ids = ["${aws_instance.demo.id}"]
  enabled      = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "demo" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags = {
    Name = "demo-instance-ec2-cloudwatch"
  }
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  namespace   = "cp"
  environment = "prod"
  delimiter   = "-"
  name        = "alerts"
  attributes  = ["ec2"]

  tags = {
    "ManagedBy" = "Terraform"
    "ModuleBy"  = "CloudPosse"
  }
}

provider "aws" {
  version = "~> 2.13"

  region = "eu-west-2"
}

provider "archive" {
  version = "~> 1.2"
}
