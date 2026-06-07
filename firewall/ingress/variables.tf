variable "project_id" {
  type        = string
  description = "The ID of the project where firewall rules will be created"
}

variable "network" {
  type        = string
  description = "The name or self_link of the network to attach the rules to"
}

variable "rules" {
  type = list(object({
    name                    = string
    description             = optional(string)
    priority                = optional(number, 1000)
    protocol                = string
    ports                   = optional(list(string))
    source_ranges           = optional(list(string))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    action                  = optional(string, "allow") # "allow" or "deny"
  }))
  description = "List of ingress firewall rules to create"
  default     = []
}
