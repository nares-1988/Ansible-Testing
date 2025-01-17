data "aws_vpc" "ansible_vpc" {
  id = "vpc-0d9d1f534c3c45c15"
}

data "aws_route_table" "ansible_vpc_rt" {
  subnet_id = "subnet-07f7dc53812c3488a"
  #If subnet_id giving errors use route table id as below
  route_table_id = "rtb-03bfff5c25b7f11a5"
}

resource "aws_vpc_peering_connection" "ansible-vpc-peering" {
  peer_vpc_id = data.aws_vpc.ansible_vpc.id
  vpc_id      = aws_vpc.default.id
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "Ansible-${var.vpc_name}-Peering"
  }
}

resource "aws_route" "peering-to-ansible-vpc" {
  route_table_id            = aws_route_table.terraform-public.id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id
  #depends_on                = [aws_route_table.terraform-public]
}

resource "aws_route" "peering-from-ansible-vpc" {
  route_table_id            = data.aws_route_table.ansible_vpc_rt.id
  destination_cidr_block    = "10.37.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id
  #depends_on                = [aws_route_table.terraform-public]
}
