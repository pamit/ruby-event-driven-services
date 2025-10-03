resource "aws_sns_topic" "order_notifications" {
  name = "order-notifications"
}

# Optional: email subscription (for testing)
resource "aws_sns_topic_subscription" "test_email" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_test_email # must confirm subscription
}
