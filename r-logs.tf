module "diagnostic_settings" {
  source  = "git::https://github.com/tothenew/terraform-azure-diagnostics.git"

  resource_id = module.lb.lb_id

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id,
    format("%s|%s", module.eventhub.namespace_send_authorization_rule.id, module.eventhub.eventhubs["logs"].name),
  ]

  log_analytics_destination_type = "Dedicated"
}
