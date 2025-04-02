# resource "aws_instance" "app_server" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.public_subnets[0].id
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]
#   iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   user_data = <<-EOF
#     #!/bin/bash

#     # Creating .env file
#     cat > /opt/csye6225/webapp/.env << 'ENVFILE'
#     DATABASE_URL="mysql://${aws_db_instance.rds_instance.username}:${var.db_password}@${aws_db_instance.rds_instance.address}/${aws_db_instance.rds_instance.db_name}"
#     TEST_DATABASE_URL="mysql://${aws_db_instance.rds_instance.username}:${var.db_password}@${aws_db_instance.rds_instance.address}/test_${aws_db_instance.rds_instance.db_name}"
#     S3_BUCKET_NAME="${aws_s3_bucket.app_bucket.bucket}"
#     AWS_REGION="${var.region}"
#     ENVFILE

#     # Set correct ownership
#     chown csye6225:csye6225 /opt/csye6225/webapp/.env
#     chmod 644 /opt/csye6225/webapp/.env


#     chown -R csye6225:csye6225 /var/log/webapp/
#     chmod -R 755 /var/log/webapp/

#     # Start the service now that .env exists
#     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch-config.json -s
#     sudo systemctl restart amazon-cloudwatch-agent
#     sudo systemctl enable amazon-cloudwatch-agent
#     systemctl start csye6225
#   EOF

#   tags = {
#     Name = "Assignment 5 EC2"
#   }

#   depends_on = [aws_vpc.my_vpc, aws_subnet.public_subnets, aws_db_instance.rds_instance, aws_s3_bucket.app_bucket]
# }
