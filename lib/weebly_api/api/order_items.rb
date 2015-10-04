require_relative "../paged_weebly_response"

module WeeblyApi
  module Api
    # Public: This is the Weebly API for Orders. It abstracts the end-points
    # of the Weebly API that deal with orders.
    class OrderItems < Base
      # Public: Gets Orders from the Weebly API
      #
      # params - optional parameters that can be used to filter the request.
      #          For a list of params, please refer to the API documentation:
      #          http://kb.weebly.com/w/page/43697230/Order%20API
      #          Note that the limit and offset parameters will be overridden
      #          since all orders will be returned and enumerated
      #
      # Returns a PagedEnumerator of `WeeblyApi::OrderItem` objects
      def all(params = {})
        PagedWeeblyResponse.new(client, "/store/orders/#{params.order_id}/items", params) do |order_item_hash|
          OrderItem.new(order_item_hash, client: client)
        end
      end

      # Public: Finds a an Order given an Weebly order_id
      #
      # order_id - an Integer that is the Weebly Order number
      #
      # Returns an WeeblyApi::Order if found, nil if not
      def find(order_id, order_item_id)
        response = client.get_with_retry("/store/orders/#{order_id}/items/#{order_item_id}", 3)
        if response.success?
          OrderItem.new(response.body, client: client)
        end
      end
    end
  end
end
