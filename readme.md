# Provisioning the Amazon EKS cluster using Terraform

## Architecture
 <img width="659" alt="image" src="https://github.com/satyam19arya/K8s_EKS_terraform/assets/77580311/aa56d89e-2ede-46d5-85a5-9f2fecad4200">


## Steps
1️⃣ Clone the repo first
```sh
git clone https://github.com/satyam19arya/K8s_EKS_terraform.git
```
2️⃣ Run the following commands
```sh
cd K8s_EKS_terraform/main
terraform init
```

3️⃣ Edit below file according to your configuration
```sh
vim K8s_EKS_terraform/main/backend.tf
```
```sh
terraform {
  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "k8s/FILE_NAME_TO_STORE_STATE.tfstate"
    region = "us-east-1"
    dynamodb_table = "dynamoDB_TABLE_NAME"
  }
}
```
### Lets setup the variable for our Infrastructure
Go to K8s_EKS_terraform/main/terraform.tfvars
```javascript
REGION           = "us-east-1"
PROJECT_NAME     = "Todo-App-EKS"
VPC_CIDR         = "172.25.0.0/16"
PUB_SUB_1_A_CIDR = "172.25.1.0/24"
PUB_SUB_2_B_CIDR = "172.25.2.0/24"
PRI_SUB_3_A_CIDR = "172.25.3.0/24"
PRI_SUB_4_B_CIDR = "172.25.4.0/24"
```
Please take note that the above file is crucial for setting up the infrastructure, so pay close attention to the values you enter for each variable.

Now run the following commands
```sh
terraform validate
terraform plan
terraform apply
```

After creating ECS cluster, run the following commands
```sh
aws eks update-kubeconfig --region REGION_NAME --name YOUR-CLUSTER-NAME
aws eks describe-cluster --name "YOUR-CLUSTER-NAME" --region REGION_NAME
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
wget https://github.com/argoproj/argo-cd/releases/download/v2.4.14/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd
argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure
kubectl apply -f argocd.yaml
echo $ARGOCD_SERVER
echo $ARGO_PWD
```
