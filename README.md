# 12-devops-bootcamp__terraform
coming up


<b><u>The advanced exercise projects are:</u></b>
*Work in Progress*
1. Provision a Linode VPS

<b><u>The basic course examples are:</u></b>
1. Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script
2. (Modularized) Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script

<b><u>The bonus projects are:</u></b>
1. Provision a Linode VPS Server with Storage and Ingress to act as a docker in docker (dind) Jenkins Server for terraform CI/CD integration

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


## Usage (Exercises)

<details closed>
<summary><b>1. wip</b></summary>

</details>

-----


## Usage (basic course examples)

<details closed>
<summary><b>1. Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script</b></summary>

a. Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

b. Create `terraform-01-ec2/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.158.109.251/32", "3.79.46.109/32"]
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
<summary><b>2. (Modularized) Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script</b></summary>

a. Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

b. Create `terraform-02-ec2-modularized/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.158.109.251/32", "3.79.46.109/32"]
public_key_location  = "~/.ssh/id_ed25519.pub"
private_key_location = "~/.ssh/id_ed25519"
```

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
<summary><b>3. wip</b></summary>

</details>

-----


## Usage (bonus projects)

<details closed>
<summary><b>1. Provision a Linode VPS Server with Storage and Ingress to act as a docker in docker (dind) Jenkins Server for terraform CI/CD integration</b></summary>

a. Setup a Linode Account and create an API TOKEN, then run script to generate `.env` file.
```bash
cd scripts/ && ./setup-linode.sh && cd ..
```

b. Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

c. Create `bonus-01-linode-jenkins/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.158.109.251/32", "3.79.46.109/32"]
public_key_content   = "ssh-ed25519 xxxxxxxxxxxxxxxxxx example.user@protonmail.com"
private_key_location = "~/.ssh/id_ed25519"
instance_type        = "g6-standard-1" # standard is the bigger version with 2 virtual cpus
```

*Note:* in case sourcing .env file does not suffice, manually export the linode token in your shell $(export LINODE_TOKEN=xxx)
```bash
cd bonus-01-linode-jenkins/
source .env
terraform init
terraform apply
```

d. Add the output public ip of your instance creation to `install-jenkins/remote.properties` and execute the remote scp/ssh installation scripts.
```bash
cd install-jenkins/
./remote-install-java.sh
# you can change the service-user password by modifying it in .env file prior to docker installation.
./remote-install-docker.sh
./remote-run-jenkins-in-docker.sh
```

e. Retrieve the initial jenkins password from the linode instance and replace the ip with your own and login and configure Jenkins to your desire.

*Note* The server is available at port your-ip:8080

*Note* When setting up admin credentials for jenkins, save them in your `.env` file or back them up properly
```bash
ssh jenkins-runner@172.105.75.118 \
docker exec jenkins-dind cat /var/jenkins_home/secrets/initialAdminPassword
```

</details>

-----