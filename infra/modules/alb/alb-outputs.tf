output "memos_alb_dns_name" {
  value = aws_lb.memos_alb.dns_name
}

output "memos_alb_zone_id" {
  value = aws_lb.memos_alb.zone_id
}

output "memos_lb_target_group_arn" {
  value = aws_lb_target_group.memos_alb_tg.arn
}