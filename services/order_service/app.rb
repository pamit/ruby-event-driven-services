require "sinatra"
require "securerandom"
require "dotenv/load"
require_relative "event_bridge"
require "sinatra/cross_origin"

puts "[order-service] Starting Order Service..."

before do
  content_type :json
end

configure do
  enable :cross_origin
end
# CORS config for localhost:5173
configure do
  set :allow_origin, 'http://localhost:5173' # Vite default port
  set :allow_methods, [:get, :post, :options]
  set :allow_credentials, true
  set :max_age, "1728000"
end
# Handle preflight OPTIONS requests
options "*" do
  response.headers["Allow"] = "HEAD,GET,POST,OPTIONS"
  response.headers["Access-Control-Allow-Origin"] = "http://localhost:5173" # Vite default port
  response.headers["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With"
  200
end

# configure do
#   enable :cross_origin
#   set :allow_origin, 'http://localhost:5173'
#   set :allow_methods, [:get, :post, :options]
#   set :allow_credentials, true
# end
# before do
#   cross_origin
#   content_type :json
# end
# options "*" do
#   200
# end

set :bind, '0.0.0.0'
set :port, 4567

post "/order" do
  content_type :json
  payload = JSON.parse(request.body.read)
  # puts "[order-service] Received order: #{payload}"

  payload["order_id"] ||= SecureRandom.uuid
  payload["placed_at"] ||= Time.now.utc.iso8601

  event_bridge = EventBridge.new
  result = event_bridge.publish_order_placed_event(payload)

  if result[:success]
    status 200
  else
    status 400
  end
  result.to_json
end
