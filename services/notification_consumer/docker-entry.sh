#!/bin/bash
set -e

# Configure AWS CLI to use LocalStack service endpoint
export AWS_ENDPOINT_URL=http://localstack:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_REGION=us-east-1

# aws configure set aws_access_key_id test
# aws configure set aws_secret_access_key test
# aws configure set default.region us-east-1
# aws configure set default.endpoint_url http://localstack:4566

QUEUE_NAME="notification-queue"
MAX_RETRIES=10
RETRY_DELAY=2

# echo "=== Testing LocalStack connection ==="
# curl -f http://localstack:4566/_localstack/health || echo "Health check failed"

for i in $(seq 1 $MAX_RETRIES); do
  # Use aws instead of awslocal
  if aws sqs get-queue-url --queue-name "$QUEUE_NAME" &>/dev/null; then
    echo "=== $QUEUE_NAME is ready! ==="
    break
  else
    echo "=== Queue not ready yet. Retrying in $RETRY_DELAY seconds... ==="
    sleep $RETRY_DELAY
  fi
  if [ "$i" -eq "$MAX_RETRIES" ]; then
    echo "=== Queue $QUEUE_NAME not found after $((MAX_RETRIES*RETRY_DELAY)) seconds. Exiting. ==="
    exit 1
  fi
done
##

# Now start Shoryuken
echo -e "\n\n=== Starting Shoryuken...==="
bundle exec shoryuken -C shoryuken.yml
