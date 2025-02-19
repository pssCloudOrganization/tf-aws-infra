resource "aws_subnet" "public_subnets" {

  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index % length(var.public_subnet_cidrs))
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {

  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block= var.private_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(var.private_subnet_cidrs))

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}
