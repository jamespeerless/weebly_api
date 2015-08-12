require_relative "paged_enumerator"

# Public: Presents a paged Weebly response as an Enumerator with a
# PagedEnumerator
#
# Example
#
#   response = PagedWeeblyResponse.new(client, "products", priceFrom: 10) do |product_hash|
#     Product.new(product_hash, click: client)
#   end
#
#   response.each do |product|
#     # do stuff the the product
#   end
#
module WeeblyApi
  class PagedWeeblyResponse
    include Enumerable
    extend  Forwardable

    def_delegator :@paged_enumerator, :each

    # Public: Initialize a new PagedWeeblyResponse
    #
    # client - an WeeblyApi::Client
    # path   - a String that is the path to retrieve from the client
    # params - a Hash of parameters to pass along with the request
    # &block - a Block that processes each item returned in the Response
    #
    def initialize(client, path, params = {}, &block)
      params[:limit] = 200
      params[:page] ||= 1
      params.delete(:offset)

      block ||= Proc.new { |item| item }
      response = client.get(path, params)

      @paged_enumerator = PagedEnumerator.new(response) do |response, yielder|
        response.body.each do |item|
          yielder << block.call(item)
        end
        total = response.headers["x-resultset-total"].to_i
        limit = response.headers["x-resultset-limit"].to_i
        page = response.headers["x-resultset-page"].to_i
        pages_processed = page - 1
        count = response.body.length
        offset = pages_processed * limit

        if count == 0 || count + offset >= total
          false
        else
          client.get(path, params.merge(page: page + 1))
        end
      end
    end
  end
end