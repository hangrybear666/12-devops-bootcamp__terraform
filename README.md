# 12-devops-bootcamp__terraform
Terraform configs & modules for EC2 provisioning, EKS cluster setup, Ansible Provisioner, CI/CD with Jenkins & Linode VPS provisioning with Jenkins(dind).


<b><u>The course examples are:</u></b>
1. Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script
2. (Modularized) Provision 1-n EC2 instances with VPC, Internet Gateway, Route Table, Security Group, Subnet & init script (remote S3 state backend)
3. Provide an EKS cluster /w 3 Nodes in a VPC with private & public subnets using predefined AWS EKS modules
4. CI-CD Terraform Integration provisioning an EC2 instance as deployment server & deploying payload in declarative Jenkins pipeline
5. Ansible Handover via provisioner: Provision 1 modularized EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet & init script (remote S3 state backend)

<b><u>The bonus projects are:</u></b>
1. Provision a Linode VPS Server with Storage and Ingress to act as a docker in docker (dind) Jenkins Server for terraform CI/CD integration
2. Provision 1-n generic Linode VPS Debian 12 Servers with a blank slate to further configure with e.g. Ansible (remote S3 state backend)
3. Provision a global S3 bucket used as terraform state backend including a lock mechanism and versioning

<b><u>The exercise projects are:</u></b>

## Setup

### 1. Pull SCM

Pull the repository locally by running
```bash
git clone https://github.com/hangrybear666/12-devops-bootcamp__terraform.git
```
### 2. Install terraform on your development machine

For debian 12 you can use the following installation script, otherwise follow https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```bash
cd scripts/ && ./install-terraform.sh
```

### 3. Setup Environment Variables with your secrets and configuration

scaffold the .env files with the following script and fill in your own details.
```bash
cd scripts/ && ./setup-env-vars.sh
```

### 4. Install AWS CLI on your development machine

Follow the steps described in https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

## Usage (course examples)

<details closed>
<summary><b>1. Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script</b></summary>

#### a. Associate SSH Key to Instance
Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

#### b. Change custom variables and apply template
Create `terraform-01-ec2/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.xxx.xxx.251/32", "3.xxx.xxx.109/32"]
public_key_location  = "~/.ssh/id_ed25519.pub"
private_key_location = "~/.ssh/id_ed25519"
```

```bash
# source environment variables, especially AWS access keys
cd terraform-01-ec2/
source .env
terraform init
terraform apply
```


</details>

-----

<details closed>
<summary><b>2. (Modularized) Provision 1-n EC2 instances with VPC, Internet Gateway, Route Table, Security Group, Subnet & init script (remote S3 state backend)</b></summary>

#### a. Associate SSH Key to Instance
Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

#### b. Provide custom variables
Create `terraform-02-ec2-modularized/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.xxx.xxx.251/32", "3.xxx.xxx.109/32"]
public_key_location  = "~/.ssh/id_ed25519.pub"
private_key_location = "~/.ssh/id_ed25519"
instance_count       = 2
```

#### c. Create S3 bucket to store terraform state to synchronize the state to remote storage as secure backup

- Simply follow bonus step 3 to setup the s3 backend used in this project's `provider.tf` file (only required once for all states).
- Change bucket = "{YOUR_S3_UNIQUE_BUCKET_NAME}" in `provider.tf` that you've set in bonus project 3.

#### d. Execute terraform configs
```bash
# source environment variables, especially AWS access keys
cd terraform-02-ec2-modularized/
source .env
terraform init
terraform apply
```

</details>

-----

<details closed>
<summary><b>3. Provide an EKS cluster /w 3 Nodes in a VPC with private & public subnets using predefined AWS EKS modules</b></summary>

#### a. Apply the template
```bash
cd terraform-03-aws-eks/
source .env
terraform init
terraform apply
```

#### b . Create IAM access entries so aws user can communicate with cluster

**In AWS Management Console:**

EKS -> Clusters -> tf-dev-eks-cluster -> IAM access entries -> Create access entry -> Policy name `AmazonEKSAdminPolicy` and `AmazonEKSClusterAdminPolicy`

#### c . Update kubeconfig to connect to cluster and check functionality
```bash
aws eks update-kubeconfig --name tf-dev-eks-cluster --region eu-central-1
kubectl get nodes
kubectl apply -f k8s-manifests/nginx-deployment.yaml
kubectl get svc
# navigate to external ip of your cloud native loadbalancer to access nginx
```

</details>

-----


<details closed>
<summary><b>4. CI-CD Terraform Integration provisioning an EC2 instance as deployment server & deploying payload in declarative Jenkins pipeline</b></summary>

#### a. Configure Jenkins for AWS, Git, Docker Hub, SSH

**Create Secrets**
- Create Username:Password with the id `docker-hub-repo` containing your user and API Token as password
- Create Username:Password with the id `git-creds` with either your username or jenkins and an API Token as password
- Create Secret Text with the id `aws_access_key_id` with your AWS IAM Account's Access Key ID (or better a dedicated Jenkins IAM Account)
- Create Secret Text with the id `aws_secret_access_key` with your AWS IAM Account's Secret Access Key (or better a dedicated Jenkins IAM Account)
- Create SSH Username:Private Key with the id `ssh-tf-ec2` and provide the aws console private key from prior step as secret. User is `ec2-user`

**Configure Jenkins Plugins**
- Add Maven Plugin under Manage Jenkins -> Tools -> Maven and name it Maven.
- Install SSH Agent Plugin under Manage Jenkins -> Plugins -> Available Plugins

**Install aws cli in jenkins docker container**
```bash
ssh jenkins-runner@172.105.75.118
docker exec -u root -it jenkins-dind bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
exit
```

**Install terraform in jenkins docker container**
```bash
ssh jenkins-runner@172.105.75.118
docker exec -u root -it jenkins-dind bash
apt update && apt install -y wget
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform
```

#### b. Create S3 bucket to store terraform state to synchronize the state to remote storage for other team members

- Create S3 bucket in AWS console  in the same region written in `provider.tf` named `tf-dev-bucket-ec2`. If you name it differently, override `bucket =` in `terraform-04-ci-cd-jenkins-provisioning/provider.tf`
- Amazon S3 -> Buckets -> Create bucket -> "tf-dev-bucket-ec2" -> ACLs disabled (recommended) -> Block all public access -> Bucket Versioning (Disable) -> Server-side encryption with Amazon S3 managed keys (SSE-S3) -> Bucket Key (Disable)

#### c. Create Jenkins Pipeline with this repository as source and Jenkinsfile located in terraform-04-ci-cd-jenkins-provisioning/java-app/Jenkinsfile

- If your region is not eu-central-1 then change it in `payload/ec2-run-ecr-image.sh`
- Replace the environment variable `AWS_ECR_REPO_URL` in `terraform-04-ci-cd-jenkins-provisioning/java-app/Jenkinsfile` with your own repository url
- Replace the environment variable `JENKINS_IP` in `terraform-04-ci-cd-jenkins-provisioning/java-app/Jenkinsfile` with your own Jenkins Server IP

#### d. Run the pipeline with your own custom parameters to whitelist your IP address and provide your aws key-pair name for ssh access

*Note:* Since custom parameters aren't initialized on first run, you should cancel the first run, until you see the "Build with Parameters" Option in Jenkins.

**IMPORTANT** To debug and interact with terraform locally e.g. to destroy resources, simply provide the necessary variables in `terraform.tfvars` instead of running the pipeline
```bash
#terraform.tfvars
my_ip               = "xxx.xxx.xxx.xxx/32"
jenkins_ip           = "xxx.xxx.xxx.xxx/32"
ssh_key_name         = "tf-ci-cd-test"
```
</details>

-----

<details closed>
<summary><b>5. Ansible Handover via provisioner: Provision 1 modularized EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet & init script (remote S3 state backend)</b></summary>

##### Info: This project installs docker and python dependencies on the EC2 machine and runs a fullstack docker compose application /w AWS ECR image after terraform calls the provisioner.

#### a. Associate SSH Key to Instance
Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

#### b. Provide custom variables
Create `terraform-05-ec2-modularized-ansible-provisioner/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`

**Important:** As the ec2 instance hands over the server config & setup to Ansible after public IPv4 has been exposed, you have to provide the absolute path to the respective ansible project (Project 4 in Ansible repo).
<u>Note:</u> Ansible script currently only supports 1 instance, as that instances public ip is hardcoded into the index.html of the deployed java-app docker image.

```bash
my_ips                 = ["62.xxx.xxx.251/32", "3.xxx.xxx.109/32"]
public_key_location    = "~/.ssh/id_ed25519.pub"
private_key_location   = "~/.ssh/id_ed25519"
instance_count         = 1
ansible_work_directory = "/home/admin/git/15-devops-bootcamp__ansible/04-ec2-deploy-docker-compose-from-terraform"
```

#### c. Create S3 bucket to store terraform state to synchronize the state to remote storage as secure backup

- Simply follow bonus step 3 to setup the s3 backend used in this project's `provider.tf` file (only required once for all states).
- Change bucket = "{YOUR_S3_UNIQUE_BUCKET_NAME}" in `provider.tf` that you've set in bonus project 3.

#### d. Follow the setup steps in the ansible project 4 from a-c to change any of your local workspace variables

- Project 4 steps a-c in https://github.com/hangrybear666/15-devops-bootcamp__ansible

#### e. Execute terraform configs
```bash
# source environment variables, especially AWS access keys
cd terraform-05-ec2-modularized-ansible-provisioner/
source .env
terraform init
terraform apply
```

</details>

-----

## Usage (bonus projects)

<details closed>
<summary><b>1. Provision a Linode VPS Server with Storage and Ingress to act as a docker in docker (dind) Jenkins Server for terraform CI/CD integration</b></summary>

#### a. Setup a Linode Account and create an API TOKEN, then run script to generate `.env` file.
```bash
cd scripts/ && ./setup-linode.sh && cd ..
```

#### b. Create Public/Private Key pair so linode vps can add the public key to its authorized_keys

#### c. Create `bonus-01-linode-jenkins/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.xxx.xxx.251/32", "3.xxx.xxx.109/32"]
public_key_content   = "ssh-ed25519 xxxxxxxxxxxxxxxxxx example.user@protonmail.com"
private_key_location = "~/.ssh/id_ed25519"
instance_type        = "g6-standard-1" # standard is the bigger version with 2 virtual cpus
```

*Note:* in case sourcing .env file does not suffice, manually export the linode token in your shell `$(export LINODE_TOKEN=xxx)`
```bash
cd bonus-01-linode-jenkins/
source .env
terraform init
terraform apply
```

#### d. Add the output public ip of your instance creation to `install-jenkins/remote.properties` and execute the remote scp/ssh installation scripts.
```bash
cd install-jenkins/
./remote-install-java.sh
# you can change the service-user password by modifying it in .env file prior to docker installation.
./remote-install-docker.sh
./remote-run-jenkins-in-docker.sh
```

#### e. Retrieve the initial jenkins password from the linode instance and replace the ip with your own and login and configure Jenkins to your desire.

*Note* The server is available at port your-ip:8080

*Note* When setting up admin credentials for jenkins, save them in your `.env` file or back them up properly
```bash
ssh jenkins-runner@172.105.75.118 \
docker exec jenkins-dind cat /var/jenkins_home/secrets/initialAdminPassword
```

</details>

-----


<details closed>
<summary><b>2. Provision 1-n generic Linode VPS Debian 12 Servers with a blank slate to further configure with e.g. Ansible (remote S3 state backend)</b></summary>

#### a. Setup a Linode Account and create an API TOKEN, then run script to generate `.env` file.
```bash
cd scripts/ && ./setup-linodes-generic.sh && cd ..
```

#### b. Create Public/Private Key pair so linode vps can add the public key to its authorized_keys

#### c. Create S3 bucket to store terraform state to synchronize the state to remote storage as secure backup

- Simply follow bonus step 3 to setup the s3 backend used in this project's `provider.tf` file (only required once for all states).
- Change bucket = "{YOUR_S3_UNIQUE_BUCKET_NAME}" in `provider.tf` that you've set in bonus project 3.

#### d. Create `bonus-02-linodes-generic/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.xxx.xxx.251/32", "3.xxx.xxx.109/32"]
public_key_content   = "ssh-ed25519 xxxxxxxxxxxxxxxxxx example.user@protonmail.com"
private_key_location = "~/.ssh/id_ed25519"
instance_type        = "g6-standard-1" # standard is the bigger version with 2 virtual cpus
http_inbound_ports   = "80, 8080-8085" # default is "80, 8080"
instance_count       = 3 # default is 1
```

*Note:* in case sourcing .env file does not suffice, manually export the linode token in your shell `$(export LINODE_TOKEN=xxx)`
```bash
cd bonus-02-linodes-generic/
source .env
terraform init
terraform apply
```

</details>

-----

<details closed>
<summary><b>3. Provision a global S3 bucket used as terraform state backend including a lock mechanism and versioning</b></summary>

#### a. Create the S3 bucket to use as backend for other terraform projects.

*Note:* in case sourcing .env file does not suffice, manually export the linode token in your shell `$(export LINODE_TOKEN=xxx)`

*Note:* region is hardcoded to `eu-central-1`. You can change this in the .tf files.
```bash
cd bonus-03-s3-state-backend/
source .env
terraform init
terraform apply
```

#### b. Change the globally unique bucket name to your own in `bonus-03-s3-state-backend/terraform.tfvars`
```bash
unique_bucket_name = "hangrybear-tf-backend-state-bucket"
```

#### c. To use in other terraform projects, simply add the backend configuration to their provider file like so

<b>IMPORTANT:</b> Each project should use a different key (folder path) in the S3 bucket.

```bash
terraform {
  required_providers {
    # ...
  }
  backend "s3" {
    bucket = "tf-backend-state-bucket"
    key = "{PROJECT_SPECIFIC_FOLDER}/state.tfstate"
    region = "eu-central-1"
    encrypt = true
    # for locking state changes in multi-user environments
    #dynamodb_table = "terraform-s3-backend-locking"
  }
}
```

#### d. To lock state in multi-user environments we can provision an Amazon DynamoDB table as a lock mechanism

- Simply uncomment the `aws_dynamodb_table` resource in `main.tf` and the backend variable in your other terraform projects

</details>

-----

## Usage (Exercises)

<details closed>
<summary><b></b></summary>

</details>

-----