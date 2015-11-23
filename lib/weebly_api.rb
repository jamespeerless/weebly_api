require "weebly_api/version"
require "ext/string"
require 'faraday'
require 'faraday_middleware'

require_relative "weebly_api/error"

# Public: This is the main namespace for the WeeblyApi. It can be used to store
# the default client.
#
module WeeblyApi
  require_relative "weebly_api/o_auth"
  require_relative "weebly_api/client"
  require_relative "weebly_api/error"
  require_relative "weebly_api/api"
  require_relative "weebly_api/entity"

  require_relative "weebly_api/order"
  require_relative "weebly_api/order_item"
  require_relative "weebly_api/site"
  require_relative "weebly_api/store"
  require_relative "weebly_api/user"
  require_relative "weebly_api/coupon"
end
