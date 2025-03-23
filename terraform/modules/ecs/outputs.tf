output "aws_ecs_cluster_id" {
  value = aws_ecs_cluster.test.id

}


output "aws_ecs_cluster_name" {
  value = aws_ecs_cluster.test.name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.test.name
}
