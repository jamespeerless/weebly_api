require_relative "../paged_weebly_response"

module WeeblyApi
  module Api
    class Products < Base
      # Public: Get all of the Product objects for the Weebly store
      #
      # Returns an Array of Product objects
      def all(params = {})
        PagedWeeblyResponse.new(client, "products", params) do |product_hash|
          Product.new(product_hash, client: client)
        end
      end

      # Public: Finds a single product by product ID
      #
      # id - an Weebly product ID
      #
      # Returns a Product object, or nil if one can't be found
      def find(id)
        response = client.get("products/#{id}")
        if response.success?
          Product.new(response.body, client: client)
        end
      end

      # Public: Finds a single Product by SKU
      #
      # sku - a SKU of a product
      #
      # Returns a Product object, or nil if one can't be found
      def find_by_sku(sku)
        all(keyword: sku).find { |product| product[:sku] == sku }
      end

      # Public: Creates a new Product
      #
      # params - a Hash
      #
      # Raises an Error if there is a problem
      #
      # Returns a Product object
      def create(params)
        response = client.post("products", params)

        raise_on_failure(response) {|response| find(response.body["id"]) }
      end

      # Public: Updates an existing Product
      #
      # id - the Weebly product ID
      # params - a Hash
      #
      # Raises an Error if there is a problem
      #
      # Returns a Product object
      def update(id, params)
        response = client.put("products/#{id}", params)

        raise_on_failure(response) { find(id) }
      end
    end
  end
end