data "aws_region" "current" {}

resource "aws_networkfirewall_rule_group" "suricata_rules" {
  capacity = 100
  name     = "${var.project}-firewall-rule"
  type     = "STATEFUL"
  
  rule_group {
    rules_source {
      rules_string = <<EOF
# Allow all traffic for Bastion (from Hub VPC)
pass ip 10.0.0.0/16 any -> any any (msg:"Allow Bastion traffic"; sid:1001;)

# Block ifconfig.io HTTP/HTTPS requests from App VPC
drop http 192.168.0.0/16 any -> any any (msg:"Block ifconfig.io HTTP"; http.host; content:"ifconfig.io"; sid:2001;)
drop tls 192.168.0.0/16 any -> any any (msg:"Block ifconfig.io HTTPS"; tls_sni; content:"ifconfig.io"; sid:2002;)
EOF
    }
  }

  tags = {
    Name = "${var.project}-firewall-rule"
  }
}

resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.project}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.suricata_rules.arn
    }
  }

  tags = {
    Name = "${var.project}-firewall-policy"
  }
}

resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.project}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id

  subnet_mapping {
    subnet_id = var.firewall_subnet_id
  }

  tags = {
    Name = "${var.project}-firewall"
  }
}

resource "aws_cloudwatch_log_group" "firewall" {
  name              = "/${var.project}/firewall"
  retention_in_days = 3

  tags = {
    Name = "${var.project}-firewall-log-group"
  }
}

resource "aws_cloudwatch_log_group" "green_app" {
  name              = "/${var.project}/app/green"
  retention_in_days = 3

  tags = {
    Name = "${var.project}-green-app-log-group"
  }
}

resource "aws_cloudwatch_log_group" "red_app" {
  name              = "/${var.project}/app/red"
  retention_in_days = 3

  tags = {
    Name = "${var.project}-red-app-log-group"
  }
}

resource "aws_cloudwatch_log_group" "codebuild_red" {
  name              = "/${var.project}/build/red"
  retention_in_days = 3

  tags = {
    Name = "${var.project}-codebuild-red-log-group"
  }
}

resource "aws_cloudwatch_log_group" "codebuild_green" {
  name              = "/${var.project}/build/green"
  retention_in_days = 3

  tags = {
    Name = "${var.project}-codebuild-green-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "green_app" {
  name           = "app-green-logs"
  log_group_name = aws_cloudwatch_log_group.green_app.name
}

resource "aws_cloudwatch_log_stream" "red_app" {
  name           = "app-red-logs"
  log_group_name = aws_cloudwatch_log_group.red_app.name
}

resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = aws_networkfirewall_firewall.main.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
} 

### ------------------------------------------------------------
### App VPC Network Firewall
### ------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "app_suricata_rules" {
  capacity = 100
  name     = "${var.project}-appvpc-nfw-rule"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = <<EOF
# Allow all traffic for Bastion (from Hub VPC)
pass ip 10.0.0.0/16 any -> any any (msg:"Allow Bastion traffic"; sid:1001;)

# Block ifconfig.io HTTP/HTTPS requests from App VPC
drop http 192.168.0.0/16 any -> any any (msg:"Block ifconfig.io HTTP"; http.host; content:"ifconfig.io"; sid:2001;)
drop tls 192.168.0.0/16 any -> any any (msg:"Block ifconfig.io HTTPS"; tls_sni; content:"ifconfig.io"; sid:2002;)
EOF
    }
  }

  tags = {
    Name = "${var.project}-appvpc-nfw-rule"
  }
}

resource "aws_networkfirewall_firewall_policy" "app" {
  name = "${var.project}-appvpc-nfw-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.app_suricata_rules.arn
    }
  }

  tags = {
    Name = "${var.project}-appvpc-nfw-policy"
  }
}

resource "aws_networkfirewall_firewall" "app" {
  name                = "${var.project}-appvpc-nfw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.app.arn
  vpc_id              = var.app_vpc_id

  dynamic "subnet_mapping" {
    for_each = var.app_firewall_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = "${var.project}-appvpc-nfw"
  }
}

resource "aws_networkfirewall_logging_configuration" "app" {
  firewall_arn = aws_networkfirewall_firewall.app.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}