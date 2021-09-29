resource "cloudflare_zone" "zone" {
  count = var.module_enabled ? 1 : 0

  depends_on = [var.module_depends_on]

  zone       = var.zone
  paused     = var.paused
  jump_start = var.jump_start
  plan       = var.plan
  type       = var.type
}

locals {
  records = { for b in var.records : "${b.type}/${b.name}" => b }
}

resource "cloudflare_record" "record" {
  for_each = var.module_enabled ? local.records : tomap({})

  zone_id         = cloudflare_zone.zone[0].id
  name            = each.value.name
  type            = each.value.type
  value           = try(each.value.value, null)
  data            = try(each.value.data, null)
  ttl             = try(each.value.ttl, null)
  priority        = try(each.value.priority, null)
  proxied         = try(each.value.proxied, false)
  allow_overwrite = try(each.value.allow_overwrite, false)
}
