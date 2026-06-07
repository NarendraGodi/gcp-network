resource "google_compute_firewall" "ingress" {
  for_each = { for r in var.rules : r.name => r }

  name        = each.value.name
  project     = var.project_id
  network     = var.network
  direction   = "INGRESS"
  priority    = each.value.priority
  description = each.value.description

  dynamic "allow" {
    for_each = each.value.action == "allow" ? [1] : []
    content {
      protocol = each.value.protocol
      ports    = each.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "deny" ? [1] : []
    content {
      protocol = each.value.protocol
      ports    = each.value.ports
    }
  }

  source_ranges           = each.value.source_ranges
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
}
