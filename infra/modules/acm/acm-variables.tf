# Input variables obtained from outside the module

variable "tags" {
  type = map(string)
}

variable "memos_alb_dns_name" {
  type = string
}

variable "memos_alb_zone_id" {
  type = string
}

variable "memos_domain" {
  type = string
}