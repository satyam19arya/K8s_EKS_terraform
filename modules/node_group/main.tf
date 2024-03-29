resource "aws_eks_node_group" "nodes_general" {
  cluster_name = var.EKS_CLUSTER_NAME
  node_group_name = "${var.EKS_CLUSTER_NAME}-NG"
  node_role_arn = var.NODE_GROUP_ARN

  subnet_ids = [
    var.PRI_SUB_3_A_ID,
    var.PRI_SUB_4_B_ID
  ]

  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 2
  }

  # Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  ami_type = "AL2_x86_64"

  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  # Disk size in GiB for worker nodes
  disk_size = 20

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
  # depends_on = [
  #   aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_general,
  #   aws_iam_role_policy_attachment.amazon_eks_cni_policy_general,
  #   aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  # ]
}