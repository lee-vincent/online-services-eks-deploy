
module "eks" {
  source                       = "terraform-aws-modules/eks/aws"
  version                      = "17.1.0"
  cluster_name                 = local.cluster_name
  cluster_version              = "1.20"
  subnets                      = module.vpc.private_subnets

  cluster_service_ipv4_cidr = "192.168.0.0/16"
  enable_irsa               = false


  cluster_endpoint_private_access_cidrs = []
  cluster_endpoint_private_access_sg    = []
  fargate_pod_execution_role_name       = ""
  permissions_boundary                  = ""
  vpc_id                                = module.vpc.vpc_id

  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 1
      asg_max_size         = 3
      asg_min_size         = 1

      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
}