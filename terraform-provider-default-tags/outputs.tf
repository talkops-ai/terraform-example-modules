# Usage: Allows other modules or providers (e.g., Datadog, Kubernetes) to inherit the exact same tagging structure for consistency.
output "default_tags" {
  description = "The map of default tags applied to the AWS provider."
  value       = local.default_tags
}
