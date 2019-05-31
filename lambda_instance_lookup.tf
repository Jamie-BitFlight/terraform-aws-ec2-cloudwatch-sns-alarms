resource "aws_iam_role" "iam_for_lambda" {
  name = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("lambda-role", "-", module.label.delimiter))}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("lambda-policy", "-", module.label.delimiter))}"
  role = "${aws_iam_role.iam_for_lambda.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.lambda_logs.arn}"
    }
  ]
}
EOF
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/index.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "${format("%s%s%s",module.label.id, module.label.delimiter, replace("lambda-function", "-", module.label.delimiter))}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "index.handler"
  source_code_hash = "${filebase64sha256(data.archive_file.lambda.output_path)}"
  runtime          = "nodejs8.10"
  timeout          = "60"
  memory_size      = "128"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = "14"
  tags              = "${module.label.tags}"
}

data "aws_lambda_invocation" "instance" {
  count         = "${local.enabled ? var.instance_ids_count : 0}"
  function_name = "${aws_lambda_function.lambda.function_name}"

  input = <<JSON
{
  "InstanceId": "${var.instance_ids[count.index]}",
  "NetworkUtilizationThreshold": "${local.thresholds["NetworkUtilizationThreshold"]}",
}
JSON
}
