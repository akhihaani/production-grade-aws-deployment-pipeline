# Project Overview
this project takes an app called memos and hosts it on Amazon ECS which can be reached publicly on the internet through HTTPS
The project is split into two scopes: Bootstrap and Infra

**Bootstrap (+build.yaml)**:

Applied locally:
- Creates an s3 bucket and dynamodb lock table which are both used for handling terraform state
- An IAM role is created for GitHub Actions to use for OIDC (avoids static AWS keys)
- Another S3 bucket is created for collecting logs for the ALB
- The ECR Repository
- The Route 53 hosted zone

CI/CD:
- A docker image of the app is created and pushed to Amazon ECR using a Github actions workflow (upon pushing to github)

**Infra**:
- Using a manual github actions workflow, we create infrastructure using terraform onto AWS
- The terraform infrastructure is split across modules to handle everything separately
- This includes creating a network for this application
- The app is hosted on ECS Tasks within the network
- An ALB is used to route incoming traffic to the ECS tasks
- And Amazon cert manager is used to secure the domain for HTTPS
- and a subdomain is delegated to route 53 from cloudflare and used for the ECS task

When the app infrastructure is deployed, the memos app is available at:
```
https://memos.abuniyyah.uk
```

## Repository structure
```
.
├─ dockerfile                 # multi-stage build for the memos image
├─ .dockerignore
├─ memos/                     # app source (git submodule → usememos/memos)
├─ bootstrap/                 # Scope 1 — applied LOCALLY (foundational state)
│  ├─ main.tf                 # state bucket, lock table, logs bucket, R53 zone, ECR, OIDC + IAM role
│  ├─ provider.tf
│  ├─ locals.tf
│  ├─ outputs.tf              # consumed by infra via terraform_remote_state
│  └─ github-tight-policy.json
├─ infra/                     # Scope 2 — applied by CI (app infrastructure)
│  ├─ backend.tf              # S3 backend + reads bootstrap remote state
│  ├─ main.tf                 # wires the modules together
│  ├─ provider.tf / variables.tf / locals.tf / outputs.tf
│  └─ modules/
│     ├─ vpc/                 # VPC, public subnets, ALB SG + ECS task SG
│     ├─ alb/                 # ALB, listeners (80→443), target group
│     ├─ acm/                 # certificate + DNS validation records
│     └─ ecs/                 # cluster, service, task def, CloudWatch log group
├─ .github/workflows/
│  ├─ build.yaml              # build & push image to ECR (push/PR/dispatch)
│  ├─ deploy.yaml             # tf fmt/validate/tflint/apply → deploy to ECS → healthcheck (dispatch)
│  └─ destroy.yaml            # terraform destroy (dispatch)
├─ documents/                 # architecture diagrams (scope 1 + scope 2)
└─ README.md
```

# Architecture Diagram
(Draw.io)

What to include:
- VPC
- Subnets (+ Three AZs clearly labeled (eu-west-2a/b/c))
- ALB
- ECS
- ECR
- ACM
- Cloudflare → Route53 NS delegation (the subdomain handoff)
- Two scopes side-by-side: bootstrap (S3 state, DynamoDB lock, Route53 zone, ECR repo OIDC provider + IAM role) vs infra (VPC, ALB, ECS, ACM, etc.)
- GitHub Actions → OIDC → IAM role trust relationship (label as OIDC, no static keys)
- The data flow: user → Cloudflare DNS → Route53 → ALB → ECS task in private container
- Security groups as boundaries (ALB SG and ECS SG) — usually shown as dashed boxes around resources
- The two S3 buckets: state bucket and ALB logs bucket
- The CloudWatch log group the container writes to


# Reproduction Instructions
the dense part. Walk through bootstrap → NS records in Cloudflare → infra apply → CI/CD.
Be honest about what's manual.

**Pre-Requisities**:
First you need to have an AWS account and you need to configure it to your local Command Line Interface.

CLI configuration:
(I dont know how to configure AWS on my CLI, i didnt know i even did this)

You also need to own a domain
Go to any domain registrar, such as cloudflare, and purchase a domain.

Fork the github repository and pull it to your working folder

Use:
git clone --recurse-submodules <your-fork-url>



**Bootstrap**:
Use:
cd bootstrap
terraform init
terraform apply

**Manual**:
- From the output of the bootstrap terraform apply, 4 nameservers are outputted
- Those must be pasted as NS records into the domain registrar of the domain (or subdomain) you own
- This delegates authority over it to route 53

**build.yaml**:
Use:
git push origin main

This will activate the build.yaml workflow
which will create a docker image and push it to Amazon ECR

The workflow can also be activated manually in the github actions menu
build.yaml must be run and completed before using deploy.yaml

**deploy.yaml**:
In the github actions menu, activate deploy.yaml
This can only be done manually

Certificate validation can take 10-15 minutes, so you will need to wait

**verify**:
Visit [https://<domain-name>] and check if it is working
[https://<domain-name>/healthz] can be used for health status checking

---

(Also how to set up locally)

## APP Demo Video

# Screenshots
Once everything is documented, you know exactly what to capture: ECS console, AWS, CI runs, the live site with HTTPS padlock.

Screenshots of successful deployment and app running live on AWS via domain

SC of pipeline succeses