# Terraform Provider Default Tags Module

Configures the AWS provider with a standardized `default_tags` block to ensure 100% tagging compliance for cost allocation and ABAC security enforcement.

## Features
- Standardized provider-level default tags (CostCenter, Owner, Project, Environment).
- Merges required compliance tags with any additional context tags.
- Provides an output of the normalized tags for use in cross-provider/cross-module situations.

## Usage Example

```hcl
module "provider_tags" {
  source = "./terraform_modules/terraform-provider-default-tags"

  aws_region  = "ap-south-1"
  cost_center = "CC-1234"
  owner       = "platform-team"
  project     = "core-infra"
  environment = "prod"

  additional_tags = {
    ManagedBy  = "Terraform"
    Compliance = "SOC2"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | ~> 6.39.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS region to deploy resources into. | `string` | `"ap-south-1"` | no |
| cost_center | The cost center identifier for billing and chargebacks. | `string` | n/a | yes |
| owner | The team or individual responsible for the resources. | `string` | n/a | yes |
| project | The project name associated with the resources. | `string` | n/a | yes |
| environment | The deployment environment (e.g., dev, staging, prod). | `string` | n/a | yes |
| additional_tags | Additional custom tags to merge with the mandatory default tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| default_tags | The map of default tags applied to the AWS provider. |

## IAM Policy Requirements

Using these default tags correctly enables Attribute-Based Access Control (ABAC). Here's an example of an IAM condition you can use:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceABACTags",
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "${aws:PrincipalTag/Environment}",
          "aws:ResourceTag/Project": "${aws:PrincipalTag/Project}",
          "aws:ResourceTag/CostCenter": "${aws:PrincipalTag/CostCenter}"
        }
      }
    }
  ]
}
```
