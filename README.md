# trellis-mvp-terraform
Trellis MVP Terraform configurations

# Terraforming instructions

## A. Install Terraform
https://learn.hashicorp.com/terraform/getting-started/install.html

## B Deploy external bastion node (optional)
The external bastion is deployed to a separate network & project from Trellis. In order to access Trellis resources such as the database and AI notebook, users will first connect to the external bastion host, then hop to the bastion host inside the Trellis project & network, and then to the Trellis resource. If you are not handling high or medium risk data, you can probably skip this and go to step 2. From the repository root directory, navigate to the external-bastion directory.

```
cd external-bastion
```

1. **Create a tfvars file.**
The tfvars file stores variable values that will be used to deploy Trellis. All of the required variables are listed in the variables.tf file. In this case you need to provide the ID of your Google Cloud project as well as the IP of local machine you will use to connect to the bastion host. If you are at Stanford, we recommend using the IP of an SCG cluster login node, since it's IP is static. The name of the tfvars file is arbitrary, just make sure it had the extension ".tfvars". Replace the values in <brackets> with your own, and run the following command to create your tfvars file.

```
printf "project=<your-project-name>\nlocal-ip=<your-local-ip>" > my.tfvars
```
  
2. **Initialize Terraform.**

```
terraform init
```

3. **Plan terraform.**
Run the 'terraform plan' operation and fix any issues that are identified.

```
terraform plan --var-file=my.tfvars 
```

4. **Apply terraforming.**

```
terraform apply --var-file=my.tfvars
```
