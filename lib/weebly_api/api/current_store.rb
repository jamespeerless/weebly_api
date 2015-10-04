module WeeblyApi
  module Api
    # Public: This is the Weebly API for Orders. It abstracts the end-points
    # of the Weebly API that deal with orders.
    class CurrentStore < Base
      def fetch
        response = client.get_with_rety("sites/#{client.site_id}/store", 3)
        if response.success?
          Store.new(response.body, client: client)
        end
      end
    end
  end
end