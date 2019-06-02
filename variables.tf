variable "instance_ids" {
  type        = "list"
  default     = []
  description = "The instance IDs of the EC2 instances that you want to monitor."
}

variable "instance_ids_count" {
  type        = "string"
  default     = "0"
  description = "The total number of instance ID's provided"
}

variable "cpu_utilization_threshold" {
  default     = "80"
  description = "The maximum percentage of CPU utilization."
}

variable "cpu_credit_balance_threshold" {
  default     = "20"
  description = "The minimum number of CPU credits (t2 instances only) available."
}

variable "network_utilization_threshold" {
  default     = "80"
  description = "The maximum percentage of network utilization."
}

## Variables Needed for all alarms
variable "enabled" {
  type        = "string"
  description = "Whether to create all resources"
  default     = "true"
}

variable "evaluation_periods" {
  type        = "string"
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "period" {
  type        = "string"
  description = "Duration in seconds to evaluate for the alarm."
  default     = "300"
}

variable "alarm_description" {
  type        = "string"
  description = "The string to format and use as the alarm description."
  default     = "Average %v utilization over last %d minute(s) too %v over %v period(s)"
}

variable "existing_sns_topic_arn" {
  description = "Pass in an existing SNS topic ARN instead of creating a new sns topic"
  default     = ""
}
