# Development Environment

This directory contains the Terraform root module for the AWS Voting Platform development environment.

The environment uses an Amazon S3 backend for remote Terraform state and native S3 state locking.

## Purpose

The development environment will manage the AWS resources used by the application, including:

* networking;
* compute resources;
* container registries;
* databases;
* caching;
* monitoring;
* security configuration.

At the current stage, this module only verifies the AWS account, region, backend configuration, and Terraform state storage.

No application infrastructure is created yet.

## Directory structure

```text
infra/environments/dev/
├── backend.hcl.example
├── locals.tf
├── outputs.tf
├── provider.tf
├── README.md
├── variables.tf
└── versions.tf
```

The local `.terraform` directory, Terraform plans, state files, and the real `backend.hcl` file are ignored by Git.

## Remote state

Terraform state is stored in the project's dedicated S3 bucket.

The development environment uses the following object key:

```text
environments/dev/terraform.tfstate
```

The state bucket is created separately by the bootstrap configuration located in:

```text
infra/bootstrap
```

The bootstrap configuration uses local state because the S3 bucket must exist before Terraform can use it as a remote backend.

The resulting architecture is:

```text
infra/bootstrap
    │
    │ local Terraform state
    ▼
creates the S3 state bucket
    │
    ▼
infra/environments/dev
    │
    │ remote Terraform state
    ▼
s3://STATE_BUCKET/environments/dev/terraform.tfstate
```

## State locking

Native S3 state locking is enabled with:

```hcl
use_lockfile = true
```

During operations that can modify Terraform state, Terraform temporarily creates a lock file:

```text
environments/dev/terraform.tfstate.tflock
```

The lock prevents two Terraform processes from modifying the same state simultaneously.

For example:

```text
Terraform process A
    └── acquires the lock and modifies infrastructure

Terraform process B
    └── cannot acquire the lock and stops with an error
```

The lock file is removed automatically after the Terraform operation finishes successfully.

Do not disable locking during normal development.

## Requirements

Install:

* Terraform 1.10 or newer;
* AWS CLI v2;
* Git.

Verify the tools:

```bash
terraform version
aws --version
git --version
```

## AWS authentication

The configuration does not contain hardcoded AWS access keys.

Terraform uses the standard AWS credential chain and the AWS CLI profile configured for the project.

Activate the project profile:

```bash
export AWS_PROFILE=aws-voting-platform
export AWS_REGION=eu-central-1
export AWS_DEFAULT_REGION=eu-central-1
```

Verify the active AWS identity:

```bash
aws sts get-caller-identity
```

The returned ARN should identify the expected IAM user or role.

If the browser-based AWS CLI session has expired, authenticate again:

```bash
aws login --profile aws-voting-platform
```

## Backend configuration

The tracked Terraform configuration contains a partial backend declaration:

```hcl
terraform {
  backend "s3" {}
}
```

The actual backend values are supplied through a local file named:

```text
backend.hcl
```

This file is intentionally ignored by Git.

A sanitized example is available at:

```text
backend.hcl.example
```

Example backend configuration:

```hcl
bucket       = "replace-with-terraform-state-bucket-name"
key          = "environments/dev/terraform.tfstate"
region       = "eu-central-1"
encrypt      = true
use_lockfile = true
```

## Create the local backend configuration

Run the following command from the repository root:

```bash
STATE_BUCKET="$(
  terraform -chdir=infra/bootstrap output -raw state_bucket_name
)"

cat > infra/environments/dev/backend.hcl <<EOF
bucket       = "${STATE_BUCKET}"
key          = "environments/dev/terraform.tfstate"
region       = "eu-central-1"
encrypt      = true
use_lockfile = true
EOF
```

Verify the generated file:

```bash
cat infra/environments/dev/backend.hcl
```

Confirm that Git ignores it:

```bash
git check-ignore -v infra/environments/dev/backend.hcl
```

The real backend configuration must not be committed.

## Initialization

Initialize the Terraform working directory from the repository root:

```bash
terraform -chdir=infra/environments/dev init \
  -backend-config=backend.hcl
```

A successful initialization should include:

```text
Successfully configured the backend "s3"!
```

Terraform will also:

* connect to the S3 backend;
* download the AWS provider;
* create the local `.terraform` working directory;
* create or update `.terraform.lock.hcl`.

The `.terraform.lock.hcl` file should be committed because it records the selected provider versions and checksums.

## Reconfiguring the backend

Run backend reconfiguration after changing backend settings or switching to a branch that changes the Terraform backend:

```bash
terraform -chdir=infra/environments/dev init \
  -reconfigure \
  -backend-config=backend.hcl
```

The `-reconfigure` option tells Terraform to use the provided backend configuration without attempting to reuse the previously initialized backend settings.

## Formatting

Format all Terraform files in the development environment:

```bash
terraform -chdir=infra/environments/dev fmt -recursive
```

Check formatting without changing files:

```bash
terraform -chdir=infra/environments/dev fmt -check -recursive
```

## Validation

Validate the Terraform configuration:

```bash
terraform -chdir=infra/environments/dev validate
```

Expected output:

```text
Success! The configuration is valid.
```

Display the required providers:

```bash
terraform -chdir=infra/environments/dev providers
```

## Planning

Create a saved Terraform plan:

```bash
terraform -chdir=infra/environments/dev plan \
  -out=tfplan
```

Inspect the saved plan:

```bash
terraform -chdir=infra/environments/dev show tfplan
```

At the current stage, the module does not create AWS resources.

The plan should show:

```text
Plan: 0 to add, 0 to change, 0 to destroy.
```

The plan can still include:

* reading the current AWS account identity;
* creating or updating Terraform outputs;
* writing the resulting state to S3.

## Applying

Apply the reviewed plan:

```bash
terraform -chdir=infra/environments/dev apply tfplan
```

The first apply creates the remote Terraform state object in S3.

It does not create a VPC, EC2 instance, database, or other application infrastructure.

## Verify the remote state

Retrieve the state bucket name:

```bash
STATE_BUCKET="$(
  terraform -chdir=infra/bootstrap output -raw state_bucket_name
)"
```

List the development state path:

```bash
aws s3 ls \
  "s3://${STATE_BUCKET}/environments/dev/"
```

Expected object:

```text
terraform.tfstate
```

The complete S3 path is:

```text
s3://STATE_BUCKET/environments/dev/terraform.tfstate
```

## Inspect the Terraform state

List resources and data sources stored in the state:

```bash
terraform -chdir=infra/environments/dev state list
```

At the current stage, the state should contain only the AWS caller identity data source:

```text
data.aws_caller_identity.current
```

Display the Terraform outputs:

```bash
terraform -chdir=infra/environments/dev output
```

Expected outputs include:

```text
aws_account_id
aws_region
environment
project_name
terraform_state_key
```

## State separation

The project intentionally uses separate Terraform states.

### Bootstrap state

Location:

```text
infra/bootstrap/terraform.tfstate
```

Responsibility:

```text
Terraform state S3 bucket
```

### Development environment state

Location:

```text
s3://STATE_BUCKET/environments/dev/terraform.tfstate
```

Future responsibilities:

```text
VPC
subnets
route tables
security groups
EC2
ECR
RDS
ElastiCache
ECS
monitoring
```

This separation reduces the risk of accidentally deleting or modifying the backend that stores the main infrastructure state.

## Files committed to Git

The following files should be committed:

```text
README.md
backend.hcl.example
locals.tf
outputs.tf
provider.tf
variables.tf
versions.tf
.terraform.lock.hcl
```

## Files excluded from Git

The following files and directories must not be committed:

```text
backend.hcl
.terraform/
tfplan
*.tfplan
*.tfstate
*.tfstate.*
*.tfvars
```

Verify ignored files:

```bash
git status --ignored --short infra/environments/dev
```

## Common commands

Initialize:

```bash
terraform -chdir=infra/environments/dev init \
  -backend-config=backend.hcl
```

Reconfigure the backend:

```bash
terraform -chdir=infra/environments/dev init \
  -reconfigure \
  -backend-config=backend.hcl
```

Format:

```bash
terraform -chdir=infra/environments/dev fmt -recursive
```

Validate:

```bash
terraform -chdir=infra/environments/dev validate
```

Plan:

```bash
terraform -chdir=infra/environments/dev plan \
  -out=tfplan
```

Inspect the plan:

```bash
terraform -chdir=infra/environments/dev show tfplan
```

Apply:

```bash
terraform -chdir=infra/environments/dev apply tfplan
```

Display outputs:

```bash
terraform -chdir=infra/environments/dev output
```

List state entries:

```bash
terraform -chdir=infra/environments/dev state list
```

## Current status

Completed:

* development environment root module;
* AWS provider configuration;
* shared resource tags;
* partial S3 backend declaration;
* local backend configuration example;
* remote state path;
* native S3 state locking;
* account and region verification;
* Terraform outputs.

Next:

* Terraform formatting and validation in CI;
* TFLint;
* infrastructure security scanning;
* VPC and subnet architecture;
* security groups;
* cost-aware networking without NAT Gateway.
