# ELASTIC KUBERNETES SERVICE Module

Production-grade EKS module designed to support high-density workloads, Karpenter integration, and comprehensive security controls.

## Usage

```hcl
module "eks" {
  source = "./terraform_modules/eks"

  name                            = "my-cluster"
  environment                     = "production"
  vpc_id                          = "vpc-0123456789abcde"
  vpc_subnet_ids                  = ["subnet-abc", "subnet-def"]
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 6.39.0 |
| tls | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name tag for all resources | `string` | n/a | yes |
| cluster\_name | Name of the EKS cluster. | `string` | `""` | no |
| environment | Environment identifier | `string` | `"production"` | no |
| vpc\_id | ID of the VPC where the EKS cluster will be deployed | `string` | n/a | yes |
| vpc\_subnet\_ids | The IDs of the subnets in the VPC that can be used by EKS | `list(string)` | n/a | yes |
| cluster\_endpoint\_private\_access | Whether the Amazon EKS private API server endpoint is enabled | `bool` | `true` | no |
| cluster\_endpoint\_public\_access | Whether the Amazon EKS public API server endpoint is enabled | `bool` | `false` | no |
| kms\_key\_enabled | Controls if a KMS key for cluster encryption should be created | `bool` | `true` | no |
| kms\_key\_arn | ARN of an existing KMS key to use if kms_key_enabled is false | `string` | `null` | no |
| cluster\_log\_types | A list of desired control plane logs to enable for the EKS cluster | `list(string)` | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` | no |
| system\_node\_group\_instance\_types | List of instance types associated with the system EKS Node Group | `list(string)` | `["c7g.large", "m7g.large"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_name | Name of the EKS cluster |
| cluster\_endpoint | Endpoint of the EKS cluster |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster |
| node\_security\_group\_id | Security group ID attached to the EKS nodes |
| oidc\_provider\_arn | The ARN of the OIDC Provider |
| oidc\_provider\_url | The URL of the OIDC Provider |
| kms\_key\_arn | The ARN of the KMS key created for cluster encryption |
| cluster\_certificate\_authority\_data | Base64 encoded certificate data required to communicate with the cluster |