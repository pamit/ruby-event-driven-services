require 'shoryuken'
require 'json'

puts "[inventory-consumer] Starting Inventory Consumer..."
puts "[inventory-consumer] AWS_REGION: #{ENV['AWS_REGION']}"
puts "[inventory-consumer] AWS_ENDPOINT: #{ENV['AWS_ENDPOINT']}"

class Worker
  include Shoryuken::Worker

  shoryuken_options queue: 'inventory-queue',
    auto_delete: true,
    body_parser: :json

  def perform(sqs_msg, body)
    puts "[inventory-consumer] Received message: #{sqs_msg} - #{body}"
    # [inventory-consumer] Received message: #<Shoryuken::Message:0x0000ffff65641f30> - {"version"=>"0", "id"=>"e3fa89c5-8bfe-de44-f93a-930aa8bb9fea", "detail-type"=>"OrderPlaced", "source"=>"order.service", "account"=>"089121592393", "time"=>"2025-10-03T14:51:47Z", "region"=>"ap-southeast-2", "resources"=>[], "detail"=>{"user_id"=>"auth0|68d73db74efe12a86501cdc1", "items"=>[{"sku"=>"ABC123", "quantity"=>1}], "total"=>19.99, "order_id"=>"a5c4cca4-094f-4515-b706-e1ab749d51d9", "placed_at"=>"2025-10-03T14:51:47Z"}}

    data = body['detail'] #JSON.parse(body)
    order_id = data['order_id']
    total = data['total']

    puts "[inventory-consumer] Processing invenstory order #{order_id}: Reserving #{total}"
    # Simulate inventory reservation logic
    puts "[inventory-consumer] Inventory reserved for order #{order_id}"
  rescue => e
    puts "[inventory-consumer] Error processing order: #{e.message}"
    raise e
  end
end
