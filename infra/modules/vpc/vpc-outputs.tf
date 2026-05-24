output "memos_subnet_1" {
  value = aws_subnet.memos_subnet_1.id
}

output "memos_subnet_2" {
  value = aws_subnet.memos_subnet_2.id
}

output "memos_subnet_3" {
  value = aws_subnet.memos_subnet_3.id
}

output "memos_public_subnets" {
  value = [
    aws_subnet.memos_subnet_1.id,
    aws_subnet.memos_subnet_2.id,
    aws_subnet.memos_subnet_3.id,
  ]
}

output "memos_alb_sg" {
  value = aws_security_group.memos_alb_sg.id
}

output "memos_ecs_task_sg" {
  value = aws_security_group.memos_ecs_task_sg.id
}

output "memos_vpc" {
  value = aws_vpc.memos_vpc.id
}