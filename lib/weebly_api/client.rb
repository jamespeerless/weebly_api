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

    def report_subscription_payment(opts)

      if Rails.env.production?
        opts[:method] = "purchase"
      else
        opts[:method] = "testpurchase"
      end

      opts[:kind] = "recurring"
      opts[:detail] = "Payment for Swell subscription for #{Date.today.month}/#{Date.today.year}"
      self.report_subscription_action(opts)
    end

    def report_subscription_refund(opts)
      if Rails.env.production?
        opts[:method] = "refund"
      else
        opts[:method] = "testrefund"
      end
      opts[:kind] = "cancel"
      opts[:detail] = "Refund for Swell subscription for #{Date.today.month}/#{Date.today.year}"
      self.report_subscription_action(opts)
    end


    def report_point_purchase(opts)
      if Rails.env.production?
        opts[:method] = "purchase"
      else
        opts[:method] = "testpurchase"
      end
      opts[:detail] = "Payment for Swell Point Purchase"
      self.report_payment_with_retry(opts, 3)
    end

    def report_point_refund(opts)
      if Rails.env.production?
        opts[:method] = "refund"
      else
        opts[:method] = "testrefund"
      end
      opts[:detail] = "Refund for Swell Point Purchase"
      self.report_payment_with_retry(opts, 3)
    end

    def report_point_action(opts)
      opts[:name] = "Swell Point Purchase"
      opts[:term] = "forever"
      opts[:kind] = "single"
      self.report_payment_with_retry(opts, 3)
    end

    def report_subscription_action(opts)
      opts[:name] = "Swell Subscription Fee"
      opts[:term] = "month"
      self.report_payment_with_retry(opts, 3)
    end

    def report_payment_with_retry(opts, retry_count = 0)
      connection = Faraday.new({:url => "#{DEFAULT_URL}/v1/", :headers => {:x_weebly_access_token => @token.reload.access_token}}) do |conn|
        conn.request  :json
        conn.response :logger
        conn.response :json
        conn.adapter  @adapter
      end

      opts[:payable_amount] = opts[:gross_amount].to_f * 0.30

      puts opts.inspect
      puts "***JSON***"
      puts opts.to_json
      Rails.logger.debug opts.inspect
      Rails.logger.debug "****JSON****"
      Rails.logger.debug opts.to_json

      response = connection.post do |req|
        req.url "admin/app/payment_notifications"
        req.headers['Content-Type'] = 'application/json'
        req.body = opts.to_json
      end

      Rails.logger.debug response.inspect

      if response.success?
        response
      elsif retry_count > 0
        self.report_payment_with_retry(opts, retry_count - 1)
      else
        response
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