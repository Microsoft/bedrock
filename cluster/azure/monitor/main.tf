resource "azurerm_monitor_action_group" "email-alert" {
  name                = "email-dri"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "email-dri"

  # email_receiver {
  #   name          = "1csdri"
  #   email_address = "1csdri@microsoft.com"
  # }

  email_receiver {
    name          = "xiaodoli"
    email_address = "xiaodoli@microsoft.com"
  }
}

resource "azurerm_monitor_action_group" "sms-alert" {
  name                = "sms-dri"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "sms-dri"

  # email_receiver {
  #   name          = "1csdri"
  #   email_address = "1csdri@microsoft.com"
  # }

  email_receiver {
    name          = "xiaodoli"
    email_address = "xiaodoli@microsoft.com"
  }
  sms_receiver {
    name         = "oncall"
    country_code = "1"
    phone_number = "2407517601"
  }
}

data "azurerm_application_insights" "app_insights" {
  name                = "${var.app_insights_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_monitor_metric_alert" "unhandled_exception_sev3" {
  count = "${var.unhandled_exception_metric_name != "" && var.sev3_enabled == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}_unhandled_exception_sev3"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev3 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.sev3_enabled}"
  frequency           = "${var.frequency}"
  severity            = 3
  window_size         = "${var.window_size}"
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.unhandled_exception_metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold        = "${var.threshold_sev3}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.email-alert.id}"
  }

  triggers = {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold_sev3   = "${var.threshold_sev3}"
    sev3_enabled     = "${var.sev3_enabled}"
    frequency        = "${var.frequency}"
    window_size      = "${var.window_size}"
  }
}

resource "azurerm_monitor_metric_alert" "unhandled_exception_sev2" {
  count = "${var.unhandled_exception_metric_name != "" && var.sev2_enabled == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}_unhandled_exception_sev2"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev2 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.sev2_enabled}"
  frequency           = "${var.frequency}"
  severity            = 2
  window_size         = "${var.window_size}"
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.unhandled_exception_metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold        = "${var.threshold_sev2}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.sms-alert.id}"
  }

  triggers = {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold_sev2   = "${var.threshold_sev2}"
    sev2_enabled     = "${var.sev2_enabled}"
    frequency        = "${var.frequency}"
    window_size      = "${var.window_size}"
  }
}

resource "azurerm_monitor_metric_alert" "heartbeat_sev3" {
  count = "${var.heartbeat_metric_name != "" && var.sev3_enabled == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}_heartbeat_sev3"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev3 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.sev3_enabled}"
  frequency           = "${var.heartbeat_frequency}"
  severity            = 3
  window_size         = "${var.heartbeat_window_size}"
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.heartbeat_metric_name}"
    aggregation      = "Count"
    operator         = "LessThanOrEqual"
    threshold        = "${var.heartbeat_threshold_sev3}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.email-alert.id}"
  }

  triggers = {
    metric_namespace      = "${var.metric_namespace}"
    heartbeat_metric_name = "${var.heartbeat_metric_name}"
    threshold_sev3        = "${var.heartbeat_threshold_sev3}"
    sev3_enabled          = "${var.sev3_enabled}"
    heartbeat_frequency   = "${var.heartbeat_frequency}"
    heartbeat_window_size = "${var.heartbeat_window_size}"
  }
}

resource "azurerm_monitor_metric_alert" "heartbeat_sev2" {
  count = "${var.heartbeat_metric_name != "" && var.sev2_enabled == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}_heartbeat_sev2"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev2 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.sev2_enabled}"
  frequency           = "${var.heartbeat_frequency}"
  severity            = 2
  window_size         = "${var.heartbeat_window_size}"
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.heartbeat_metric_name}"
    aggregation      = "Count"
    operator         = "LessThanOrEqual"
    threshold        = "${var.heartbeat_threshold_sev2}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.sms-alert.id}"
  }

  triggers = {
    metric_namespace      = "${var.metric_namespace}"
    heartbeat_metric_name = "${var.heartbeat_metric_name}"
    threshold_sev2        = "${var.heartbeat_threshold_sev2}"
    sev2_enabled          = "${var.sev2_enabled}"
    heartbeat_frequency   = "${var.heartbeat_frequency}"
    heartbeat_window_size = "${var.heartbeat_window_size}"
  }
}

resource "azurerm_application_insights_web_test" "ping" {
  count = "${var.status_url != "" && var.pingable == "true" ? 1 : 0}"

  name                    = "${var.metric_namespace}_webtest"
  location                = "${var.location}"
  resource_group_name     = "${var.resource_group_name}"
  application_insights_id = "${data.azurerm_application_insights.app_insights.id}"
  kind                    = "ping"
  frequency               = 300
  timeout                 = 15
  enabled                 = "${var.pingable}"
  geo_locations           = ["us-ca-sjc-azr", "us-va-ash-azr"]                     # web test regions: https://github.com/Azure/azure-quickstart-templates/blob/master/201-dynamic-web-tests/README.md

  configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="${var.status_url}" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

  triggers = {
    metric_namespace = "${var.metric_namespace}"
    pingable         = "${var.pingable}"
    status_url       = "${var.status_url}"
  }
}

resource "azurerm_monitor_metric_alertrule" "availability" {
  count = "${var.status_url != "" && var.pingable == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}_availability"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  description         = "An alert rule to watch the status ping results"
  enabled             = "${var.pingable}"

  resource_id = "${azurerm_application_insights_web_test.ping[0].id}"
  metric_name = "availability"
  operator    = "GreaterThan"
  threshold   = 0.9
  aggregation = "Average"
  period      = "PT5M"

  email_action {
    send_to_service_owners = false

    custom_emails = [
      "1csdri@microsoft.com",
    ]
  }

  triggers = {
    metric_namespace = "${var.metric_namespace}"
    pingable         = "${var.pingable}"
    status_url       = "${var.status_url}"
  }
}
