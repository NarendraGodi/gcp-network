variable "target_env" {
  type        = string
  description = "The environment to deploy (dev, nonprod, or prod)"
  validation {
    condition     = contains(["dev", "nonprod", "prod"], var.target_env)
    error_message = "target_env must be one of: dev, nonprod, prod."
  }
}

variable "GOOGLE_CREDENTIALS" {
  description = "GCP Service Account Key (Sensitive)"
  type        = string
  default     = null
  sensitive   = true
}

variable "deletion_policy" {
  description = "The deletion policy for the project (DELETE or PREVENT)"
  type        = string
  default     = "DELETE"
}
