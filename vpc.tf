resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}" #10.0.0.0/16
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-vpc",
    },
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-internet-gateway",
    },
  )
}

resource "aws_subnet" "public_subnet-01" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public_subnet-01_cidr}" #10.0.0.0/24
  availability_zone       = "${var.public_subnet-01_az}" #ap-southeast-2b
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.gw]

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-public-subnet-01",
    },
  )
}

resource "aws_subnet" "public_subnet-02" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public_subnet-02_cidr}" #10.0.1.0/24
  availability_zone       = "${var.public_subnet-02_az}" #ap-southeast-2c
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.gw]

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-public-subnet-02",
    },
  )
}

resource "aws_subnet" "private_subnet-01" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.private_subnet-01_cidr}" #10.0.2.0/24
  availability_zone       = "${var.private_subnet-01_az}" #ap-southeast-2b

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-private-subnet-01",
    },
  )
}

resource "aws_subnet" "private_subnet-02" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.private_subnet-02_cidr}" #10.0.3.0/24
  availability_zone       = "${var.private_subnet-02_az}" #ap-southeast-2c

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-private-subnet-02",
    },
  )
}

resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route = []

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-default-route-table",
    },
  )
}

resource "aws_eip" "nat_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet-01.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-nat-gw",
    },
  )
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private_subnets-to-internet_route" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-private-subnets-route",
    },
  )
}

resource "aws_route" "route-private" {
  route_table_id            = aws_route_table.private_subnets-to-internet_route.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat_gw.id
  depends_on                = [aws_route_table.private_subnets-to-internet_route]
}

resource "aws_route_table_association" "private_subnet-assoc-01" {
  subnet_id      = aws_subnet.private_subnet-01.id
  route_table_id = aws_route_table.private_subnets-to-internet_route.id
}

resource "aws_route_table_association" "private_subnet-assoc-02" {
  subnet_id      = aws_subnet.private_subnet-02.id
  route_table_id = aws_route_table.private_subnets-to-internet_route.id
}

resource "aws_route_table" "public_subnet-to-igw_route" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-public-subnets-route",
    },
  )
}

resource "aws_route" "route-public" {
  route_table_id            = aws_route_table.public_subnet-to-igw_route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
  depends_on                = [aws_route_table.public_subnet-to-igw_route]
}

resource "aws_route_table_association" "public_subnet-assoc-01" {
  subnet_id      = aws_subnet.public_subnet-01.id
  route_table_id = aws_route_table.public_subnet-to-igw_route.id
}

resource "aws_route_table_association" "public_subnet-assoc-02" {
  subnet_id      = aws_subnet.public_subnet-02.id
  route_table_id = aws_route_table.public_subnet-to-igw_route.id
}