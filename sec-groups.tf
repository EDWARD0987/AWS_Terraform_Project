# -------------------------------------------------------------------------------------
# App Server Security Group
# -------------------------------------------------------------------------------------

resource "aws_security_group" "app_server_sg" {
  name        = "${var.ProjectName}-${var.env}-app-server-sg"
  description = "SG of App Server"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
  )
}

resource "aws_security_group_rule" "in_8080_app-svr_from_alb" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "8080 from ALB to App Server"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "out_https_app-svr" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "HTTPS from App Svr to Internet"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "out_http_app-svr" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "HTTP from App Svr to Internet"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# -------------------------------------------------------------------------------------
# ALB Security Group
# -------------------------------------------------------------------------------------

resource "aws_security_group" "alb_sg" {
  name        = "${var.ProjectName}-${var.env}-alb-sg"
  description = "SG of ALB"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
  )
}

resource "aws_security_group_rule" "in_https_alb" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "HTTPS from internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "in_80_alb" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "4040 traffic from internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "out_8080_alb_to_app" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "8080 from ALB to App Server"
  type              = "egress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.app_server_sg.id
}