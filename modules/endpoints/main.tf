resource "aws_security_group" "allow_vpc_endpoint" {
  name        = "MGMT-VPC-Endpoints-Traffic-SG"
  description = "Allow traffic across org to vpc endpoints"
  vpc_id      = var.vpc_id
  tags = {
    Name = "MGMT-VPC-Endpoints-Traffic-SG"
  }
}

resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_vpc_endpoint.id
}
resource "aws_vpc_endpoint" "interface" {

  for_each            = var.interface_endpoints
  service_name        = each.key
  vpc_id              = var.vpc_id
  private_dns_enabled = false
  subnet_ids          = var.subnet_ids
  security_group_ids  = ["${aws_security_group.allow_vpc_endpoint.id}"]
  tags = {
    Name = each.key
    PHZ  = each.value.phz
  }
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.gateway_endpoints

  service_name      = each.key
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = each.value.route_table_ids

  tags = {
    Name = each.key
  }
}

resource "aws_route53_zone" "interface_phz" {
  for_each = var.interface_endpoints
  name     = each.value.phz
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to attacheded VPCs because a management is handled by lambda
      # updates these based on some ruleset managed elsewhere.
      vpc,
    ]
  }
}

resource "aws_route53_record" "dev-ns" {
  for_each = var.interface_endpoints
  zone_id  = aws_route53_zone.interface_phz[each.key].zone_id
  name     = each.value.phz
  type     = "A"
  alias {
    name                   = aws_vpc_endpoint.interface[each.key].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.interface[each.key].dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
}