resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Name = "app-load-balancer"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    port                = var.app_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "app-target-group"
  }
}

# resource "aws_lb_listener" "app_listener" {
#   load_balancer_arn = aws_lb.app_lb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }
resource "aws_lb_listener" "app_https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}