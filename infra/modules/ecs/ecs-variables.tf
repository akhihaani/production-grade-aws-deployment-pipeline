# Input variables obtained from outside the module

variable "tags" {
  type = map(string)
}

variable "memos_repo_url" {
  type = string
}

variable "memos_lb_target_group_arn" {
  type = string
}

variable "memos_ecs_task_sg" {
  type = string
}

variable "memos_public_subnets" {
  type = list(string)
}