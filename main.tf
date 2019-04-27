provider "aws" {
  version = ">= 1.7"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# resource "aws_key_pair" "moog_IT" {
#   key_name = "${var.ami_key_pair_name}"
# }

resource "aws_instance" "it-moogsoft" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  key_name = "${var.ami_key_pair_name}"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-one.id}"
  associate_public_ip_address = true
  tags {
    Name = "${var.ami_name}"
  }
  provisioner "local-exec" {
        command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ./it_key.pem -i '${aws_instance.it-moogsoft.public_ip},' master.yml"
    }
}

resource "aws_vpc" "it-env" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "it-env"
  }
}

resource "aws_eip" "ip-it-env" {
  instance = "${aws_instance.it-moogsoft.id}"
  vpc      = true
}

resource "aws_subnet" "subnet-one" {
  cidr_block = "${cidrsubnet(aws_vpc.it-env.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.it-env.id}"
  availability_zone = "${var.availability_zone}"
}

resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.it-env.id}"
// Moog public IP with 32 to only allow connections within this IP
ingress {
    cidr_blocks = ["50.201.162.2/32"]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags {
   Name = "it-moog"
 }
}

resource "aws_internet_gateway" "it-env-gw" {
  vpc_id = "${aws_vpc.it-env.id}"
tags {
    Name = "it-env-gw"
  }
}

resource "aws_route_table" "route-table-it-env" {
  vpc_id = "${aws_vpc.it-env.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.it-env-gw.id}"
  }
tags {
    Name = "it-env-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-one.id}"
  route_table_id = "${aws_route_table.route-table-it-env.id}"
}

# resource "null_resource" "provision" {
#   triggers {
#     public_ip = "${aws_instance.it-moogsoft.public_ip}"
#   }
#
#   connection {
#     agent = true
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "bash <(curl -s -S -L https://git.io/install-gam)",
#     ]
#   }
# }
