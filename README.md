# 12-devops-bootcamp__terraform
coming up


<b><u>The advanced exercise projects are:</u></b>
*Work in Progress*
1. wip

<b><u>The basic course examples are:</u></b>
1. Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script
2. 

## Setup

### 1. Pull SCM

Pull the repository locally by running
```bash
git clone https://github.com/hangrybear666/12-devops-bootcamp__terraform.git
```
### 2. Install terraform on your development machine

For debian 12 you can use the following installation script, otherwise follow https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```bash
cd scripts && ./install-terraform.sh
```

### 3. Setup Environment Variables with your secrets and configuration

scaffold the .env files with the following script and fill in your own details.
```bash
cd scripts && ./setup-env-vars.sh
```

### 4. Initialize Project

```bash
terraform init
```

## Usage (Exercises)

<details closed>
<summary><b>1. wip</b></summary>

</details>

-----


## Usage (basic course examples)

<details closed>
<summary><b>1. Provision an EC2 instance with VPC, Internet Gateway, Route Table, Security Group, Subnet and initialization bash script</b></summary>

a. Create `terraform-01-ec2/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.158.109.251/32", "18.153.13.88/32"]
public_key_location  = "~/.ssh/id_ed25519.pub"
private_key_location = "~/.ssh/id_ed25519"
```

```bash
# source environment variables, especially AWS access keys
source .env
cd terraform-01-ec2
terraform init
terraform apply
```

b. TODO overwrite terraform.tfvars my_ip for security


</details>

-----

<details closed>
<summary><b>2. wip</b></summary>

</details>

-----