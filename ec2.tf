resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Assignment 4 EC2"
  }

  depends_on = [aws_vpc.my_vpc, aws_subnet.public_subnets]
}
