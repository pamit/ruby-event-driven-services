require 'shoryuken'
require 'json'
require 'aws-sdk-ses'
require 'aws-sdk-sns'
require 'mail'
# require_relative 'localstack-config' # Load LocalStack config

puts "[notification-consumer] Starting Notification Consumer..."
puts "[notification-consumer] AWS_REGION: #{ENV['AWS_REGION']}"
puts "[notification-consumer] AWS_ENDPOINT: #{ENV['AWS_ENDPOINT']}"

# Mail gem config for MailHog SMTP (local)
Mail.defaults do
  delivery_method :smtp,
    address: ENV.fetch("MAILHOG_SMTP_HOST", "mailhog"),
    port: ENV.fetch("MAILHOG_SMTP_PORT", 1025).to_i
end

class Worker
  include Shoryuken::Worker

  shoryuken_options queue: 'notification-queue',
    auto_delete: true,
    body_parser: :json

  AWS_REGION = ENV.fetch("AWS_REGION", "ap-southeast-2")
  USE_SNS = ENV.fetch("USE_SNS", "false") == "true"
  USE_SES = ENV.fetch("USE_SES", "false") == "true"

  def perform(sqs_msg, body)
    data = body['detail'] #JSON.parse(body)
    user_email = ENV.fetch("SES_RECIPIENT")
    order_id = data["order_id"]

    recipient = ENV.fetch("SES_RECIPIENT", "test@example.com")
    subject = "Your order #{data['order_id']} is received"
    text = "Thanks for your order of #{data['items'].map{|i| "#{i['quantity']}x #{i['sku']}"}.join(', ')} total $#{data['total']}"

    puts "[notification-consumer] Preparing to send notification for order #{order_id} to #{user_email} - use_sns=#{USE_SNS}, use_ses=#{USE_SES}"

    if USE_SNS
      send_notification(subject, text)
    elsif USE_SES
      send_mail(user_email, subject, text)
    else
      send_email_mailhog(user_email, subject, text)
    end

    puts "[notification-consumer] Sent notification email to #{user_email} for order #{order_id}"
  rescue => e
    puts "[notification-consumer] Error processing order: #{e.message}"
    raise e
  end

  private

  def ses
    @ses ||= Aws::SES::Client.new(region: AWS_REGION)
  end

  def sns
    @sns ||= Aws::SNS::Client.new(region: AWS_REGION)
  end

  def send_email(to, subject, text)
    # Use SES (SES needs verified identity in region)
    ses.send_email({
      destination: { to_addresses: [to]},
      message: {
        body: { text: { charset: "UTF-8", data: text } },
        subject: { charset: "UTF-8", data: subject }
      },
      source: "noreply@yourdomain.com"
    })

    puts "[notification-consumer] Sent via SES"
  end

  def send_notification(subject, text)
    # Publish to SNS topic (make sure topic created & subscription exists)
    sns.publish(
      topic_arn: ENV.fetch("SNS_TOPIC_ARN"),
      message: text,
    )

    puts "[notification-consumer] Published to SNS"
  end

  def send_email_mailhog(to, subject, text)
    # Local SMTP via MailHog
    Mail.deliver do
      from    ENV.fetch("MAILHOG_FROM", "no-reply@example.com")
      to      to
      subject subject
      body    text
    end

    puts "[notification-consumer] Published to Mailhog"
  end
end
