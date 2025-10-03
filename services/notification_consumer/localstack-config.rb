# LocalStack config
if ENV["AWS_ENDPOINT"] != nil
  require 'aws-sdk-sqs'

  Aws.config.update(
    region: ENV.fetch("AWS_REGION"),
    access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
    secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
    endpoint: ENV.fetch("AWS_ENDPOINT"),
  )

  Shoryuken.configure_client do |config|
    config.sqs_client = Aws::SQS::Client.new(
      region: ENV.fetch("AWS_REGION"),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
      endpoint: ENV.fetch("AWS_ENDPOINT")
    )
  end

  Shoryuken.configure_server do |config|
    config.sqs_client = Aws::SQS::Client.new(
      region: ENV.fetch("AWS_REGION"),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
      endpoint: ENV.fetch("AWS_ENDPOINT")
    )
  end

  # Test SQS connection
  begin
    sqs = Aws::SQS::Client.new
    response = sqs.list_queues
    puts "[notification-consumer] Successfully connected to SQS. Queues: #{response.queue_urls}"
  rescue => e
    puts "[notification-consumer] Failed to connect to SQS: #{e.message}"
    puts e.backtrace
  end
end
