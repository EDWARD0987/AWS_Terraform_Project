resource "aws_lb" "alb" {
  name               = "${var.ProjectName}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet-01.id, aws_subnet.public_subnet-02.id]

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb-logs.bucket
    prefix  = "${var.ProjectName}-alb"
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-alb",
    },
  )
}

resource "aws_lb_listener" "alb_app_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-app-target-grp-web.arn
  }
}

resource "aws_lb_target_group" "alb-app-target-grp-web" {
  name     = "${var.env}-alb-web-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-499"
    path                = "/"
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-alb-tg-8080",
    },
  )
}

resource "aws_lb_target_group_attachment" "alb_app_target_group_web_attachment" {
  target_group_arn = aws_lb_target_group.alb-app-target-grp-web.arn
  target_id        = aws_instance.app_server_ec2.id
  port             = 8080
}