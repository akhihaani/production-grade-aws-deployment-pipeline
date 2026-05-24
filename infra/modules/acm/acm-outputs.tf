output "memos_cert_valid" {
  value = aws_acm_certificate_validation.memos_cert_valid.certificate_arn
}