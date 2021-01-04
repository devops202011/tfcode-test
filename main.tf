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



ingress {
from_port=80
to_port=80
protocol="tcp"  
#cidr_blocks=[aws_security_group.elb-sg.arn]
security_groups=[aws_security_group.elb-sg.arn]
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


resource "aws_security_group" "elb-sg" {
  name = "terraform-sample-elb-sg"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "asg-lc" {
  key_name = aws_key_pair.terraform.key_name
  image_id          = "ami-03c3a7e4263fd998c"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start  httpd
              systemctl status httpd
              nohup busybox httpd -f -p 80 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_elb" "sample" {
  name               = "terraform-asg-sample"
  security_groups    = [aws_security_group.elb-sg.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target              = "TCP:80"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }

  # Adding a listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}




resource "aws_autoscaling_group" "asg-sample" {
  launch_configuration = aws_launch_configuration.asg-lc.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size = 1
  max_size = 1

  load_balancers    = [aws_elb.sample.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-sample"
    propagate_at_launch = true
  }
}



output "elb_dns_name" {
  value       = aws_elb.sample.dns_name
  description = "The domain name of the load balancer"
}