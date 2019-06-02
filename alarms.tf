locals {
  thresholds = {
    CPUUtilizationThreshold     = "${min(max(var.cpu_utilization_threshold, 0), 100)}"
    CPUCreditBalanceThreshold   = "${max(var.cpu_credit_balance_threshold, 0)}"
    NetworkUtilizationThreshold = "${min(max(var.network_utilization_threshold, 0), 100)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  count               = "${local.enabled ? var.instance_ids_count : 0}"
  depends_on          = ["null_resource.dependancy_check"]
  alarm_name          = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("cpu-util-too-high", "-", module.label.delimiter))}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${var.period}"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUUtilizationThreshold"]}"
  alarm_description   = "${format(var.alarm_description, "CPU", var.period/60, "high", var.evaluation_periods)}"
  alarm_actions       = ["${local.sns_topic_arn}"]
  ok_actions          = ["${local.sns_topic_arn}"]
  treat_missing_data  = "notBreaching"

  dimensions = {
    "InstanceId" = "${var.instance_ids[count.index]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  count               = "${local.enabled ? var.instance_ids_count : 0}"
  depends_on          = ["null_resource.dependancy_check"]
  alarm_name          = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("cpu-credit-balance-too-low", "-", module.label.delimiter))}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/EC2"
  period              = "${var.period}"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUCreditBalanceThreshold"]}"
  alarm_description   = "${format(var.alarm_description, "CPU credit balance", var.period/60, "low", var.evaluation_periods)}"
  alarm_actions       = ["${local.sns_topic_arn}"]
  ok_actions          = ["${local.sns_topic_arn}"]
  treat_missing_data  = "notBreaching"

  dimensions = {
    "InstanceId" = "${var.instance_ids[count.index]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_alarm" {
  count               = "${local.enabled ? var.instance_ids_count : 0}"
  depends_on          = ["null_resource.dependancy_check"]
  alarm_name          = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("status-check-failed-alarm", "-", module.label.delimiter))}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "${var.period}"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "${format(var.alarm_description, "CPU credit balance", var.period/60, "low", var.evaluation_periods)}"
  alarm_actions       = ["${local.sns_topic_arn}"]
  ok_actions          = ["${local.sns_topic_arn}"]
  treat_missing_data  = "notBreaching"

  dimensions = {
    "InstanceId" = "${var.instance_ids[count.index]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "network_burst_utilisation_too_high" {
  count               = "${local.enabled ? var.instance_ids_count : 0}"
  depends_on          = ["null_resource.dependancy_check"]
  alarm_name          = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("network-burst-util-too-high", "-", module.label.delimiter))}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  period              = "${var.period}"
  threshold           = "${element(data.aws_lambda_invocation.instance.*.result_map["NetworkBurst"], count.index)}"
  alarm_description   = "${format(var.alarm_description, "Network In+Out burst utilization", var.period/60, "high", var.evaluation_periods)}"
  alarm_actions       = ["${local.sns_topic_arn}"]
  ok_actions          = ["${local.sns_topic_arn}"]
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "inout"
    expression  = "(in+out)/60*8/1000/1000/1000" //Gigabits per second
    label       = "In+Out"
    return_data = "true"
  }

  metric_query {
    id          = "in"
    label       = "In"
    return_data = "false"

    metric {
      metric_name = "NetworkIn"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"

      dimensions = {
        "InstanceId" = "${var.instance_ids[count.index]}"
      }
    }
  }

  metric_query {
    id          = "out"
    label       = "Out"
    return_data = "false"

    metric {
      metric_name = "NetworkOut"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"

      dimensions = {
        "InstanceId" = "${var.instance_ids[count.index]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "network_baseline_utilisation_too_high" {
  count               = "${local.enabled ? var.instance_ids_count : 0}"
  depends_on          = ["null_resource.dependancy_check"]
  alarm_name          = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("network-baseline-util-too-high", "-", module.label.delimiter))}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  period              = "${var.period}"
  threshold           = "${element(data.aws_lambda_invocation.instance.*.result_map["NetworkBaseline"], count.index)}"
  alarm_description   = "${format(var.alarm_description, "Network In+Out baseline utilization", var.period/60, "high", var.evaluation_periods)}"
  alarm_actions       = ["${local.sns_topic_arn}"]
  ok_actions          = ["${local.sns_topic_arn}"]
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "inout"
    expression  = "(in+out)/60*8/1000/1000/1000" //Gigabits per second
    label       = "In+Out"
    return_data = "true"
  }

  metric_query {
    id          = "in"
    label       = "In"
    return_data = "false"

    metric {
      metric_name = "NetworkIn"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"

      dimensions = {
        "InstanceId" = "${var.instance_ids[count.index]}"
      }
    }
  }

  metric_query {
    id          = "out"
    label       = "Out"
    return_data = "false"

    metric {
      metric_name = "NetworkOut"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"

      dimensions = {
        "InstanceId" = "${var.instance_ids[count.index]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "network_maximum_utilisation_too_high" {
  count               = "${local.enabled ? var.instance_ids_count : 0}"
  depends_on          = ["null_resource.dependancy_check"]
  alarm_name          = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("network-util-too-high", "-", module.label.delimiter))}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  period              = "${var.period}"
  threshold           = "${element(data.aws_lambda_invocation.instance.*.result_map["NetworkMaximum"], count.index)}"
  alarm_description   = "${format(var.alarm_description, "Network In+Out utilization", var.period/60, "high", var.evaluation_periods)}"
  alarm_actions       = ["${local.sns_topic_arn}"]
  ok_actions          = ["${local.sns_topic_arn}"]
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "inout"
    expression  = "(in+out)/60*8/1000/1000/1000" //Gigabits per second
    label       = "In+Out"
    return_data = "true"
  }

  metric_query {
    id          = "in"
    label       = "In"
    return_data = "false"

    metric {
      metric_name = "NetworkIn"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"

      dimensions = {
        "InstanceId" = "${var.instance_ids[count.index]}"
      }
    }
  }

  metric_query {
    id          = "out"
    label       = "Out"
    return_data = "false"

    metric {
      metric_name = "NetworkOut"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"

      dimensions = {
        "InstanceId" = "${var.instance_ids[count.index]}"
      }
    }
  }
}
