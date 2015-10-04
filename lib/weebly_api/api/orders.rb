require_relative "../paged_weebly_response"

module WeeblyApi
  module Api
    # Public: This is the Weebly API for Orders. It abstracts the end-points
    # of the Weebly API that deal with orders.
    class Orders < Base
      # Public: Gets Orders from the Weebly API
      #
      # params - optional parameters that can be used to filter the request.
      #          For a list of params, please refer to the API documentation:
      #          http://kb.weebly.com/w/page/43697230/Order%20API
      #          Note that the limit and offset parameters will be overridden
      #          since all orders will be returned and enumerated
      #
      # Returns a PagedEnumerator of `WeeblyApi::Order` objects
      def all(params = {})
        PagedWeeblyResponse.new(client, "sites/#{client.site_id}/store/orders", params) do |order_hash|
          order_hash
        end
      end

      # Public: Finds a an Order given an Weebly order_id
      #
      # order_id - an Integer that is the Weebly Order number
      #
      # Returns an WeeblyApi::Order if found, nil if not
      def find(order_id)
        response = client.get_with_retry("sites/#{client.site_id}/store/orders/#{order_id}", 3)
        if response.success?
          Order.new(response.body, client: client)
        end
      end
    end
  end
end
