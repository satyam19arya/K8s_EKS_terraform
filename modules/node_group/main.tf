resource "aws_eks_node_group" "nodes_general" {
  # Name of the EKS Cluster.
  cluster_name = var.EKS_CLUSTER_NAME

  # Name of the EKS Node Group.
  node_group_name = "${var.EKS_CLUSTER_NAME}-NG"

  # Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
  node_role_arn = var.NODE_GROUP_ARN

  subnet_ids = [
    var.PRI_SUB_3_A_ID,
    var.PRI_SUB_4_B_ID
  ]

  scaling_config {
    # Desired number of worker nodes.
    desired_size = 2

    # Maximum number of worker nodes.
    max_size = 2

    # Minimum number of worker nodes.
    min_size = 2
  }

  # Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  ami_type = "AL2_x86_64"

  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  # Disk size in GiB for worker nodes
  disk_size = 20

  # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  force_update_version = false

  # List of instance types associated with the EKS Node Group
  instance_types = ["t3.medium"]

  labels = {
    role = "${var.EKS_CLUSTER_NAME}-Node-group-role",
    name = "${var.EKS_CLUSTER_NAME}-NG"
  }

  # Kubernetes version
  version = "1.27"

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
}