require "cgi"
require "ostruct"

module WeeblyApi
  # Public: Authentication objects manage OAuth authentication with an Weebly
  #         store.
  #
  # Examples
  #
  #   app = WeeblyApi::Authentication.new do |config|
  #     # see initialize for configuration
  #   end
  #
  #   app.oauth_url  # send the user here to authorize the app
  #
  #   token = app.access_token(params[:code]) # this is the code they provide
  #                                           # to the redirect_uri
  #   token.access_token
  #   token.store_id      # these are what you need to access the API
  #
  class OAuth
    CONFIG = %w(client_id client_secret scope redirect_uri user_id site_id next_oauth_url)
    attr_accessor *CONFIG

    # Public: Initializes a new Weebly Authentication for OAuth
    #
    # Examples
    #
    #   app = WeeblyApi::Authentication.new do |config|
    #     config.client_id     = "some client id"
    #     config.client_secret = "some client secret"
    #     config.scope         "this_is_what_i_want_to_do oh_and_that_too"
    #     config.redirect_uri  = "https://example.com/oauth"
    #   end
    #
    def initialize
      yield(self) if block_given?
      CONFIG.each do |method|
        raise Error.new("#{method} is required to initialize a new WeeblyApi::Authentication") unless send(method)
      end
    end

    # Public: The URL for OAuth authorization.
    #
    # This is the URL that the user will need to go to to authorize the app
    # with the Weebly store.
    #
    def oauth_url
      next_oauth_url + "?" + oauth_query
    end

    # Public: Obtain the access token in order to use the API
    #
    # code - the temporary code obtained from the authorization callback
    #
    # Examples
    #
    #   token = app.access_token(params[:code])
    #   token.access_token  # the access token that authenticates each API request
    #   token.store_id      # the authenticated Weebly store_id
    #
    # Returns an OpenStruct which responds with the information needed to
    # access the API for a store.
    def access_token(code)

      response = connection.post do |req|
        req.url "/app-center/oauth/access_token"
        req.headers['Content-Type'] = 'application/json'
        req.body = {:client_id => client_id, :client_secret => client_secret, :authorization_code => code}.to_json
      end

      if response.success?
        OpenStruct.new(response.body)
      else
        raise Error.new(response.body["error_description"])
      end
    end

    private

    # Private: The query parameters for the OAuth authorization request
    #
    # Returns a String of query parameters
    def oauth_query
      {
        client_id:     client_id,
        scope:         scope,
        user_id:       user_id,
        site_id:       site_id,
        response_type: "code",
        redirect_uri:  redirect_uri
      }.map do |key, val|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(val.to_s)}"
      end.join(?&)
    end

    # Private: Returns a connection for obtaining an access token from Weebly
    #
    def connection
      if next_oauth_url.nil? || next_oauth_url.empty?
        host = "https://www.weebly.com"
      else
        host = "https://" + URI.parse(next_oauth_url).host
      end

      @connection ||= Faraday.new host do |conn|
        conn.adapter  Faraday.default_adapter
        conn.response :json
      end
    end
  end
end