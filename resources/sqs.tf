resource "aws_sqs_queue" "inventory_queue" {
  name                       = "inventory-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600
}

resource "aws_sqs_queue" "notification_queue" {
  name                       = "notification-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600
}

# Allow EventBridge to send messages to SQS (queue policy)
resource "aws_sqs_queue_policy" "inventory_policy" {
  queue_url = aws_sqs_queue.inventory_queue.id

  policy    = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = ["sqs:SendMessage", "sqs:SendMessageBatch"]
      Resource  = aws_sqs_queue.inventory_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_cloudwatch_event_rule.order_placed_rule.arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "notification_policy" {
  queue_url = aws_sqs_queue.notification_queue.id

  policy    = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = ["sqs:SendMessage", "sqs:SendMessageBatch"]
      Resource  = aws_sqs_queue.notification_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_cloudwatch_event_rule.order_placed_rule.arn
        }
      }
    }]
  })
}
