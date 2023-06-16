# # Define the target group: This is going to provide a resource for use with Load Balancer.
resource "aws_lb_target_group" "my-target-group" {
  health_check {
    protocol            = "HTTP"
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
  name        = "demo-tg-alb"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}
# ## # Define the load balancer 

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.privet_subnet.id]

  tags = {
    Environment = "production"
  }
}

# ### security_group for load balancer 
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow TLS inbound traffic"

  dynamic "ingress" {
    for_each = [80]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## # Provides a Load Balancer Listener resource
resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}

# # Provides the ability to register instances with an Application Load Balancer (ALB)
resource "aws_lb_target_group_attachment" "ec2-alb-tg-1" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.my-target-group.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}



