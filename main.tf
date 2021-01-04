# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "example" {
ami = "ami-03c3a7e4263fd998c"
instance_type = "t2.micro"
tags ={ Name = "TF-Ec2"
        Environment= "Dev"
		}
}