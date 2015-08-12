module WeeblyApi
  module Api
    # Public: This is the Weebly API for Orders. It abstracts the end-points
    # of the Weebly API that deal with orders.
    class CurrentUser < Base
      def fetch
        response = client.get("")
        if response.success?
          User.new(response.body, client: client)
        end
      end
    end
  end
end