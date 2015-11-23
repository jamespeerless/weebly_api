require_relative "../paged_weebly_response"

module WeeblyApi
  module Api
    # Public: This is the Weebly API for Coupons. It abstracts the end-points
    # of the Weebly API that deal with coupons.
    class Coupons < Base
      # Public: Gets Coupons from the Weebly API
      #
      # params - optional parameters that can be used to filter the request.
      #          For a list of params, please refer to the API documentation:
      #          http://kb.weebly.com/w/page/43697230/Coupon%20API
      #          Note that the limit and offset parameters will be overridden
      #          since all coupons will be returned and enumerated
      #
      # Returns a PagedEnumerator of `WeeblyApi::Coupon` objects
      def all(params = {})
        PagedWeeblyResponse.new(client, "sites/#{client.site_id}/store/coupons", params) do |coupon_hash|
          coupon_hash
        end
      end

      # Public: Finds a an Coupon given an Weebly coupon_id
      #
      # coupon_id - an Integer that is the Weebly Coupon number
      #
      # Returns an WeeblyApi::Coupon if found, nil if not
      def find(coupon_id)
        response = client.get_with_retry("sites/#{client.site_id}/store/coupons/#{coupon_id}", 3)
        if response.success?
          Coupon.new(response.body, client: client)
        end
      end
    end
  end
end
