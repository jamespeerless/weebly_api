module WeeblyApi
  module Api
    # Public: This is the Weebly API for Orders. It abstracts the end-points
    # of the Weebly API that deal with orders.
    class CurrentSite < Base
      def fetch
        response = client.get("sites/#{client.site_id}")
        if response.success?
          Site.new(response.body, client: client)
        end
      end
    end
  end
end