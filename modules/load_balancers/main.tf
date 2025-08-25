resource "aws_lb" "external_nlb" {
  name               = "${var.project}-app-external-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.app_public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-app-external-nlb"
  }
}

resource "aws_lb" "internal_nlb" {
  name               = "${var.project}-app-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.app_private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-app-internal-nlb"
  }
}

resource "aws_lb" "internal_alb" {
  name               = "${var.project}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.app_private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-app-alb"
  }
}

resource "aws_lb" "argo_external_nlb" {
  name               = "${var.project}-argo-external-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.app_public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-argo-external-nlb"
  }
}

resource "aws_lb" "argo_internal_nlb" {
  name               = "${var.project}-argo-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.app_private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-argo-internal-nlb"
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.app_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project}-alb-sg"
  }
}

resource "aws_lb_target_group" "external_nlb" {
  name        = "${var.project}-app-external-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project}-app-external-nlb-tg"
  }
}

resource "aws_lb_target_group" "internal_nlb" {
  name        = "${var.project}-app-internal-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project}-app-internal-nlb-tg"
  }
}

resource "aws_lb_target_group" "internal_alb" {
  name        = "${var.project}-app-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project}-app-alb-tg"
  }
}

resource "aws_lb_target_group" "argo_external_nlb" {
  name        = "${var.project}-argo-external-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project}-argo-external-nlb-tg"
  }
}

resource "aws_lb_target_group" "argo_internal_nlb" {
  name        = "${var.project}-argo-internal-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project}-argo-internal-nlb-tg"
  }
}

resource "aws_lb_listener" "external_nlb" {
  load_balancer_arn = aws_lb.external_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_nlb.arn
  }
}

resource "aws_lb_listener" "internal_nlb" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_nlb.arn
  }
}

resource "aws_lb_listener" "internal_alb" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service not available"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_rule" "red_app" {
  listener_arn = aws_lb_listener.internal_alb.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_alb.arn
  }

  condition {
    path_pattern {
      values = ["/red*"]
    }
  }
}

resource "aws_lb_listener_rule" "green_app" {
  listener_arn = aws_lb_listener.internal_alb.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_alb.arn
  }

  condition {
    path_pattern {
      values = ["/green*"]
    }
  }
}

resource "aws_lb_listener" "argo_external_nlb" {
  load_balancer_arn = aws_lb.argo_external_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argo_external_nlb.arn
  }
}

resource "aws_lb_listener" "argo_internal_nlb" {
  load_balancer_arn = aws_lb.argo_internal_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argo_internal_nlb.arn
  }
} 