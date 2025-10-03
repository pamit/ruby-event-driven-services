require "aws-sdk-eventbridge"
require "json"
require "json-schema"

puts "[event-bridge] Starting Order Service..."
puts "[event-bridge] AWS_REGION: #{ENV['AWS_REGION']}"
puts "[event-bridge] AWS_ENDPOINT: #{ENV['AWS_ENDPOINT']}"

class EventBridge
  SCHEMA_PATH = File.expand_path("schemas/order_placed.json", __dir__)
  ORDER_SCHEMA = JSON.parse(File.read(SCHEMA_PATH))

  EVENT_BRIDGE_BUS = ENV.fetch("EVENT_BRIDGE_BUS", "default")
  EVENT_BRIDGE_SOURCE = "order.service"
  EVENT_BRIDGE_DETAIL_TYPE = "OrderPlaced"

  def initialize
    if ENV["AWS_ENDPOINT"] == nil
      @client ||= Aws::EventBridge::Client.new(region: ENV.fetch("AWS_REGION"))
    else
      # LocalStack dev setup
      @client ||= Aws::EventBridge::Client.new(
        region: ENV.fetch("AWS_REGION"),
        endpoint: ENV["AWS_ENDPOINT"],
        access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
        secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
      )
    end
  end

  def publish_order_placed_event(payload)
    begin
      JSON::Validator.validate!(ORDER_SCHEMA, payload)
      puts "[event-bridge] Payload validation successful!"
    rescue JSON::Schema::ValidationError => e
      puts "[event-bridge] Schema validation error: #{e.message}"
      status 400
      return {
        success: false,
        error: "Invalid order payload: #{e.message}"
      }.to_json
    end

    begin
      entry = {
        source: EVENT_BRIDGE_SOURCE,
        detail_type: EVENT_BRIDGE_DETAIL_TYPE,
        detail: payload.to_json,
        event_bus_name: EVENT_BRIDGE_BUS
      }

      puts "[event-bridge] Publishing event to EventBridge: #{entry}"
      response = @client.put_events(entries: [entry])
      puts "[event-bridge] EventBridge response: #{response.to_h}"

      if response.failed_entry_count > 0
        failures = response.entries.select { |e| e.error_code }
        puts "[event-bridge] EventBridge failures: #{failures.map(&:to_h)}"
        return {
          success: false,
          error: "EventBridge failed to accept event",
          details: failures.map(&:error_message)
        }
      end

      {
        success: true,
        message: "Event published",
        order_id: payload["order_id"]
      }
    rescue Aws::EventBridge::Errors::ServiceError => e
      puts "[event-bridge] AWS EventBridge error: #{e.message}"

      {
        success: false,
        error: "AWS EventBridge error: #{e.message}"
      }
    end
  end
end
