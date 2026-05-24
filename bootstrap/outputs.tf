output "memos_name_servers" {
  value = aws_route53_zone.memos_hosted_zone.name_servers
}

output "memos_lb_logs_bucket_id" {
  value = aws_s3_bucket.memos_lb_logs_bucket_id.id
}