resource "aws_autoscaling_policy" "cpu-up-policy" {
  name ="cpu-up-policy"
  autoscaling_group_name=aws_autoscaling_group.asg-sample.name
  adjustment_type ="ChangeInCapacity"
  scaling_adjustment="1"
  cooldown ="300"
  policy_type ="SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-up-alarm" {
alarm_name = "cpu-up-alarm"
alarm_description="cpu-up-alarm"
comparison_operator="GreaterThanOrEqualToThreshold"
evaluation_periods="2"
metric_name="CPUUtilization"
namespace="AWS/EC2"
period="120"
statistic="Average"
threshold="30"
dimensions= { 
  "AutoScalingGroupName" = aws_autoscaling_group.asg-sample.name
}

actions_enabled= true
alarm_actions= [aws_autoscaling_policy.cpu-up-policy.arn]
}


resource "aws_autoscaling_policy" "cpu-down-policy" {
  name ="cpu-down-policy"
  autoscaling_group_name=aws_autoscaling_group.asg-sample.name
  adjustment_type ="ChangeInCapacity"
  scaling_adjustment="-1"
  cooldown ="300"
  policy_type ="SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-down-alarm" {
alarm_name = "cpu-down-alarm"
alarm_description="cpu-down-alarm"
comparison_operator="GreaterThanOrEqualToThreshold"
evaluation_periods="2"
metric_name="CPUUtilization"
namespace="AWS/EC2"
period="120"
statistic="Average"
threshold="5"
dimensions= { 
  "AutoScalingGroupName" = aws_autoscaling_group.asg-sample.name
}

actions_enabled= true
alarm_actions= [aws_autoscaling_policy.cpu-down-policy.arn]
}