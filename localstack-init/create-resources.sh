#!/bin/bash
set -e

# --- Queues ---
QUEUES=("inventory-queue" "notification-queue")

echo -e "\n\n=== Creating SQS queues ==="
for q in "${QUEUES[@]}"; do
  awslocal sqs create-queue --queue-name "$q"
done

# --- EventBridge bus and rule ---
EVENT_BUS="order-bus"
RULE_NAME="order-placed-to-inventory"
EVENT_PATTERN='{"source":["order.service"],"detail-type":["OrderPlaced"]}'

echo -e "\n\n=== Creating EventBridge bus and rule ==="
awslocal events create-event-bus --name "$EVENT_BUS"
awslocal events put-rule \
  --name "$RULE_NAME" \
  --event-bus-name "$EVENT_BUS" \
  --event-pattern "$EVENT_PATTERN" \
  --description "Route OrderPlaced events to SQS queues"

# --- Attach targets and set queue policies ---
echo -e "\n\n=== Attaching EventBridge targets and setting policies ==="
for q in "${QUEUES[@]}"; do
  QUEUE_URL="http://localhost:4566/000000000000/$q"

  # Get queue ARN
  QUEUE_ARN=$(awslocal sqs get-queue-attributes \
    --queue-url "$QUEUE_URL" \
    --attribute-names QueueArn \
    --query "Attributes.QueueArn" \
    --output text)

  # Attach queue as EventBridge target
  awslocal events put-targets \
    --rule "$RULE_NAME" \
    --event-bus-name "$EVENT_BUS" \
    --targets "Id=$q","Arn=$QUEUE_ARN"

### LocalStack SQS policy currently not working

#   # --- Set queue policy safely ---
#   POLICY_FILE="/tmp/${q}-policy.json"
#   cat > "$POLICY_FILE" <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [{
#     "Effect": "Allow",
#     "Principal": { "Service": "events.amazonaws.com" },
#     "Action": ["sqs:SendMessage", "sqs:SendMessageBatch"],
#     "Resource": "$QUEUE_ARN",
#     "Condition": { "ArnEquals": { "aws:SourceArn": "arn:aws:events:ap-southeast-2:000000000000:rule/$RULE_NAME" } }
#   }]
# }
# EOF

#   # Convert policy to single line to avoid CLI parsing errors
#   POLICY_ONE_LINE=$(tr -d '\n' < "$POLICY_FILE")
#   awslocal sqs set-queue-attributes --queue-url "$QUEUE_URL" --attributes "Policy=$POLICY_ONE_LINE"
done

### LocalStack Schemas currently not working

# # --- Schemas ---
# echo -e "\n\n=== Creating Schemas ==="
# SCHEMA_REGISTRY="order-registry"
# SCHEMA_NAME="OrderPlaced"
# SCHEMA_FILE="/etc/localstack/init/ready.d/schemas/order_placed.json"

# awslocal schemas create-registry --registry-name "$SCHEMA_REGISTRY" --description "Schemas for orders/events"
# awslocal schemas create-schema \
#   --registry-name "$SCHEMA_REGISTRY" \
#   --name "$SCHEMA_NAME" \
#   --type JSONSchemaDraft4 \
#   --content "file://$SCHEMA_FILE"

echo -e "\n\n=== Done creating SQS queues, EventBridge bus/rules/targets, and schemas ==="
