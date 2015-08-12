module WeeblyApi
  module Api
    # Internal: A base class for common API functionality
    class Base
      include Api

      # Public: Initializes a new WeeblyApi
      #
      # client - The WeeblyApi::Client to use with the API
      #
      def initialize(client)
        @client = client
        raise Error.new("The client cannot be nil") unless client
      end
    end
  end
end