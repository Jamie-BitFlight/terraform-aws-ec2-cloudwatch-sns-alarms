terraform {
  version = "< 0.12"
}

data "aws_caller_identity" "default" {}

resource "null_resource" "dependancy_check" {
  triggers {
    instanceIds = "${join(",", var.instance_ids)}"
  }
}

locals {
  enabled = "${var.enabled == "true" ? 1 : 0}"
}

# Make a topic
resource "aws_sns_topic" "default" {
  count       = "${local.enabled}"
  name_prefix = "ec2-threshold-alerts"
}

resource "aws_sns_topic_policy" "default" {
  count  = "${local.enabled}"
  arn    = "${aws_sns_topic.default.arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count     = "${local.enabled}"
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = ["${aws_sns_topic.default.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${data.aws_caller_identity.default.account_id}",
      ]
    }
  }

  statement {
    sid       = "Allow CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = ["${aws_sns_topic.default.arn}"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}