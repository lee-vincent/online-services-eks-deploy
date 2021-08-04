output "instance_ami" {
  value = ["${aws_instance.ubuntu[*].ami}"]
}

output "instance_arn" {
  value = ["${aws_instance.ubuntu[*].arn}"]
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "workspace" {
  value = terraform.workspace
}