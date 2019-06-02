## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_description | The string to format and use as the alarm description. | string | `Average %v utilization over last %d minute(s) too %v over %v period(s)` | no |
| attributes | List of attributes to add to label. | list | `<list>` | no |
| context | A context output from a label module | map | `<map>` | no |
| cpu_credit_balance_threshold | The minimum number of CPU credits (t2 instances only) available. | string | `20` | no |
| cpu_utilization_threshold | The maximum percentage of CPU utilization. | string | `80` | no |
| delimiter | The delimiter to be used in labels. | string | `-` | no |
| enabled | Whether to create all resources | string | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`) | string | `` | no |
| evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| existing_sns_topic_arn | Pass in an existing SNS topic ARN instead of creating a new sns topic | string | `` | no |
| instance_ids | The instance IDs of the EC2 instances that you want to monitor. | list | `<list>` | no |
| instance_ids_count | The total number of instance ID's provided | string | `0` | no |
| name | Name (unique identifier for app or service) | string | `` | no |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `` | no |
| network_utilization_threshold | The maximum percentage of network utilization. | string | `80` | no |
| period | Duration in seconds to evaluate for the alarm. | string | `300` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |
| tags | Map of key-value pairs to use for tags. | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | The ARN of the SNS topic |
| sns_topic_name | The name of the SNS topic |

