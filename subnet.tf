resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr_1
  depends_on = [ aws_vpc.my_vpc ]

  tags = {
    Name = var.subnet_name_1
  }
}