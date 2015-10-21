module WeeblyApi
  # Public: Client objects manage the connection and interface to a single Weebly
  # store.
  #
  # Examples
  #
  #   client = WeeblyApi::Client.new(token: 'the access_token')
  #   client.get "/orders"
  #
  class Client
    extend Forwardable

    # The default base URL for the Weebly API
    DEFAULT_URL = "https://api.weebly.com/"

    # Public: Returns the Weebly site ID
    attr_reader :site_id
    attr_reader :token
    attr_reader :adapter

    attr_reader :connection, :orders, :products, :store, :user, :site

    # Public: Initializes a new Client to interact with the API
    #
    # token    - the authorization token provided by oAuth. See the
    #            Authentication class
    #
    def initialize(site_id, token, adapter = Faraday.default_adapter)
      @site_id, @token, @adapter = site_id, token, adapter

      self.reset_connection
      
      @orders     = Api::Orders.new(self)
      @products   = Api::Products.new(self)
      @store      = Api::CurrentStore.new(self)
      @user       = Api::CurrentUser.new(self)
      @site       = Api::CurrentSite.new(self)
    end

    def reset_connection
      @connection = Faraday.new({:url => user_url, :headers => {:x_weebly_access_token => @token.reload.access_token}}) do |conn|
        conn.request  :json
        conn.response :json
        conn.adapter  @adapter
      end
    end

    # Public: The URL of the API for the Weebly Site
    def user_url
      "#{DEFAULT_URL}/v1/user/"
    end

    def get_with_params_retry(url, params, retry_count = 0)
      response = get(url, params)
      if response.success?
        response
      elsif retry_count > 0
        self.reset_connection
        get_with_params_retry(url, params, retry_count - 1)
      else
        response
      end
    end

    def get_with_retry(url, retry_count = 0)
      response = get(url)
      if response.success?
        response
      elsif retry_count > 0
        self.reset_connection
        get_with_retry(url, retry_count - 1)
      else
        response
      end
    end

    def_delegators :connection, :get, :post, :put, :delete
  end
end