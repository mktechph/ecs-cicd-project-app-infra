output "output_app_alb" {
  value = aws_lb.app-alb.arn
}
output "output_app_nlb" {
  value = aws_lb.app-nlb.arn
}
output "output_network_alb" {
  value = aws_lb.network-alb.arn
}