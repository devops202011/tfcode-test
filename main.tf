/*
create key for keypair using >>> ec2-with_keypair>

on cmd on same dir>> ssh-keygen -f tf_ec2_key

*/


# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "terraform" {
    key_name = "my_ec2-key"
    public_key = file("tf_ec2_key.pub")
}



resource "aws_security_group" "allow_sg" {
name="ec2_sg_rules"
description="ec2_sg_rules"
#vpc_id=data.aws_vpc.My_VPC.id


ingress {
from_port=22
to_port=22
protocol="tcp"  
cidr_blocks=["0.0.0.0/0"]
}


egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    Name = "tf_sg_rules"
  }
}

resource "aws_instance" "example" {
ami = "ami-03c3a7e4263fd998c"
instance_type = "t2.micro"
key_name = aws_key_pair.terraform.key_name
vpc_security_group_ids=[aws_security_group.allow_sg.id]
tags ={ Name = "TF-Ec2"
        Environment= "Dev"
		}
}