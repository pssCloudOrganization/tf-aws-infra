resource "aws_launch_template" "app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }

  monitoring {
    enabled = true
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y || apt-get update -y
    yum install -y unzip curl || apt-get install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    export PATH=$PATH:/usr/local/bin
    # Get DB password from Secrets Manager
    DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_password.id} --region ${var.region} --query SecretString --output text)

    cat > /opt/csye6225/webapp/.env << ENVFILE
    DATABASE_URL="mysql://${aws_db_instance.rds_instance.username}:$DB_PASSWORD@${aws_db_instance.rds_instance.address}/${aws_db_instance.rds_instance.db_name}"
    TEST_DATABASE_URL="mysql://${aws_db_instance.rds_instance.username}:$DB_PASSWORD@${aws_db_instance.rds_instance.address}/test_${aws_db_instance.rds_instance.db_name}"
    S3_BUCKET_NAME="${aws_s3_bucket.app_bucket.bucket}"
    AWS_REGION="${var.region}"
    ENVFILE
    # Set correct ownership
    chown csye6225:csye6225 /opt/csye6225/webapp/.env
    chmod 644 /opt/csye6225/webapp/.env
    
    chown -R csye6225:csye6225 /var/log/webapp/
    chmod -R 755 /var/log/webapp/
    
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch-config.json -s
    sudo systemctl restart amazon-cloudwatch-agent
    sudo systemctl enable amazon-cloudwatch-agent
    systemctl start csye6225
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG-Instance"
    }
  }

  depends_on = [aws_db_instance.rds_instance, aws_s3_bucket.app_bucket]
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-autoscaling-group"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  default_cooldown          = var.default_cooldown
  default_instance_warmup   = 300
  health_check_grace_period = 300
  vpc_zone_identifier       = aws_subnet.public_subnets[*].id
  target_group_arns         = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  alarm_description   = "Scale up when CPU exceeds threshold %"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  alarm_description   = "Scale down when CPU is below threshold %"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}
