terraform {
  backend "s3" {
    bucket         = "terraform-state-file-2-tier-app"
    key            = "k8s/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "2-tier-app"
  }
}