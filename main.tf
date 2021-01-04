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


resource "aws_instance" "example" {
ami = "ami-03c3a7e4263fd998c"
instance_type = "t2.micro"
key_name = aws_key_pair.terraform.key_name
tags ={ Name = "TF-Ec2"
        Environment= "Dev"
		}
}