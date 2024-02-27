resource "aws_eks_cluster" "eks" {
  name = var.PROJECT_NAME
  role_arn = var.EKS_CLUSTER_ROLE_ARN

  # Desired Kubernetes master version
  version = "1.27"

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true

    # Must be in at least two different availability zones
    subnet_ids = [
      var.PUB_SUB_1_A_ID,
      var.PUB_SUB_2_B_ID,
      var.PRI_SUB_3_A_ID,
      var.PRI_SUB_4_B_ID
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  # depends_on = [ 
  #   aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  # ]
}