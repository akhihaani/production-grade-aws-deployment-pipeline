# ALB

resource "aws_lb" "memos_alb" {
  name               = "memos-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.memos_alb_sg]
  subnets            = var.memos_public_subnets

  access_logs {
    bucket  = var.memos_lb_logs
    prefix  = "memos-alb-access-logs"
    enabled = true
  }

  health_check_logs {
    bucket  = var.memos_lb_logs
    prefix  = "memos-alb-healthcheck-logs"
    enabled = true
  }

  tags = var.tags
}

# target group

resource "aws_lb_target_group" "memos_alb_tg" {
  name            = "memos-alb-tg"
  port            = 8081
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"
  vpc_id          = var.memos_vpc

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    matcher             = 200
    path                = "/healthz"
    port                = "traffic-port"
  }
}

# Listeners

## Forward Listener

resource "aws_lb_listener" "memos_alb_forward_listener" {
  load_balancer_arn = aws_lb.memos_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.memos_cert_valid

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.memos_alb_tg.arn
  }
}

## redirect listener

resource "aws_lb_listener" "memos_alb_redirect_listener" {
  load_balancer_arn = aws_lb.memos_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}