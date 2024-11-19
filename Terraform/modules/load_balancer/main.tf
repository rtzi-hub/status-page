# module "iam" {
#   source = "../iam"
# }

# resource "aws_elb" "this" {
#   name               = "y-r-load-balancer"
#   subnets            = var.subnet_ids

#   listener {
#     instance_port     = 8000
#     instance_protocol = "HTTP"
#     lb_port          = 80
#     lb_protocol      = "HTTP"
#   }

#   health_check {
#     target              = "HTTP:8000/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold  = 2
#     unhealthy_threshold = 2
#   }

#   tags = {
#     Name = "Y-R-LoadBalancer"
#     Project = "TeamE"
#   }
# }
