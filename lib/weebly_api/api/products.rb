require_relative "../paged_weebly_response"

module WeeblyApi
  module Api
    # Public: This is the Weebly API for Products. It abstracts the end-points
    # of the Weebly API that deal with products.
    class Products < Base
      # Public: Gets Products from the Weebly API
      #
      # params - optional parameters that can be used to filter the request.
      #          For a list of params, please refer to the API documentation:
      #          http://kb.weebly.com/w/page/43697230/Product%20API
      #          Note that the limit and offset parameters will be overridden
      #          since all products will be returned and enumerated
      #
      # Returns a PagedEnumerator of `WeeblyApi::Product` objects
      def all(params = {})
        PagedWeeblyResponse.new(client, "sites/#{client.site_id}/store/products", params) do |product_hash|
          product_hash
        end
      end

      # Public: Finds a an Product given an Weebly product_id
      #
      # product_id - an Integer that is the Weebly Product number
      #
      # Returns an WeeblyApi::Product if found, nil if not
      def find(product_id)
        response = client.get_with_retry("sites/#{client.site_id}/store/products/#{product_id}", 3)
        if response.success?
          Product.new(response.body, client: client)
        end
      end
    end
  end
end
