output "stark_repository_arn" {
  description = "Full ARN of the stark repository."
  value       = module.ecr_stark.repository_arn
}

output "stark_repository_registry_id" {
  description = "The registry ID where the stark repository was created."
  value       = module.ecr_stark.repository_registry_id
}

output "stark_repository_url" {
  description = "The URL of the stark repository."
  value       = module.ecr_stark.repository_url
}