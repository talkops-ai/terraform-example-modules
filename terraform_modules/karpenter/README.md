# KARPENTER Module

Terraform module to provision AWS infrastructure for Karpenter, including IAM roles via EKS Pod Identity, SQS queues for Spot interruptions, and EventBridge rules.

## Usage

```hcl
module "karpenter" {
  source = "./terraform_modules/karpenter"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 6.39.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster\_endpoint | Endpoint of the EKS cluster | `string` | n/a | yes |
| oidc\_provider\_arn | The ARN of the OIDC Provider | `string` | n/a | yes |
| environment | Environment identifier | `string` | `"production"` | no |
| create\_karpenter\_iam\_role | Controls if the Karpenter IAM role should be created | `bool` | `true` | no |
| k8s\_service\_account\_namespace | The namespace for the Karpenter service account | `string` | `"kube-system"` | no |
| k8s\_service\_account\_name | The name of the Karpenter service account | `string` | `"karpenter"` | no |
| enable\_spot\_interruption\_handling | Controls if the SQS queue and EventBridge rules should be created | `bool` | `true` | no |
| sqs\_enable\_encryption | Controls if KMS encryption should be enabled on the SQS queue | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| karpenter\_controller\_role\_arn | ARN of the IAM role for the Karpenter controller |
| karpenter\_controller\_role\_name | Name of the IAM role for the Karpenter controller |
| karpenter\_node\_role\_arn | ARN of the IAM role for Karpenter provisioned EC2 nodes |
| karpenter\_node\_instance\_profile\_name | Name of the IAM instance profile for Karpenter provisioned EC2 nodes |
| karpenter\_interruption\_queue\_name | Name of the SQS queue for Karpenter interruption handling |
| karpenter\_interruption\_queue\_arn | ARN of the SQS queue for Karpenter interruption handling |