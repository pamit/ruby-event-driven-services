resource "aws_cloudwatch_event_bus" "order_bus" {
  name = "order-bus"
}

# EventBridge rule that matches OrderPlaced events
resource "aws_cloudwatch_event_rule" "order_placed_rule" {
  name           = "order-placed-to-inventory"
  description    = "Rule to capture order created events and send to inventory SQS"
  event_bus_name = aws_cloudwatch_event_bus.order_bus.name
  event_pattern = jsonencode({
    source      = ["order.service"]
    detail-type = ["OrderPlaced"]
  })
}

# EventBridge targets: forward to SQS queues
resource "aws_cloudwatch_event_target" "order_placed_to_inventory_sqs" {
  rule      = aws_cloudwatch_event_rule.order_placed_rule.name
  arn       = aws_sqs_queue.inventory_queue.arn
  target_id = "inventory-sqs"
  event_bus_name = aws_cloudwatch_event_bus.order_bus.name
}

resource "aws_cloudwatch_event_target" "order_placed_to_notification_sqs" {
  rule      = aws_cloudwatch_event_rule.order_placed_rule.name
  arn       = aws_sqs_queue.notification_queue.arn
  target_id = "notification-sqs"
  event_bus_name = aws_cloudwatch_event_bus.order_bus.name
}

# Schemas
resource "aws_schemas_registry" "order_registry" {
  name        = "order-registry"
  description = "Schemas for orders/events"
}

resource "aws_schemas_schema" "order_placed" {
  registry_name = aws_schemas_registry.order_registry.name
  name          = "OrderPlaced"
  type          = "JSONSchemaDraft4"
  content       = file("${path.module}/schemas/order_placed.json")
}

resource "aws_cloudwatch_log_group" "order_bus_logs" {
  name              = "/aws/events/order-bus"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_connection" "order_bus_logging" {
  name = "order-bus-logging"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "dummy"  # required but ignored for logging
      value = "dummy"
    }
  }
}

resource "aws_cloudwatch_event_rule" "order_bus_all_events" {
  name           = "order-bus-all-events"
  description    = "Log all events from the order-bus"
  event_bus_name = aws_cloudwatch_event_bus.order_bus.name
  event_pattern = jsonencode({
    "source": ["*"],
    "detail-type": ["*"]
  })
}

resource "aws_cloudwatch_event_target" "order_bus_to_logs" {
  rule           = aws_cloudwatch_event_rule.order_bus_all_events.name
  event_bus_name = aws_cloudwatch_event_bus.order_bus.name
  arn            = aws_cloudwatch_log_group.order_bus_logs.arn
}
