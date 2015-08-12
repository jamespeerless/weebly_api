# WeeblyApi

A gem to interface with the Weebly REST APIs.

[Weebly's API Documentation](http://api.weebly.com) will be an important reference
in order to understand what their API is capable of.

## Installation

Add this line to your application's Gemfile:

    gem 'weebly_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install weebly_api

## Usage

### Get Authorized with OAuth2

Weebly API uses OAuth2 to authorize 3rd party apps to use the API with a
site. The `WeeblyApi::OAuth` class helps facilitate this process. Once you
get setup with a `client_id` and `client_secret` from Weebly, configure a new
instance like so:

    @auth = WeeblyApi::OAuth.new do |config|
      config.client_id = "the client id"
      config.client_secret = "the client secret (shh...)"
      config.request_uri   = "https://example.com/oauth"
      config.scope         = "the_permissions_i_want"
    end

The `#oauth_url` method will provide the URL that the user needs to go to
to authorize your application with their site. It can be used in Rails like so:

    link_to @auth.oauth_url, "Click here to Authorize this Groovy App!"

When the user authorizes your app, they will be redirected to the `request_uri`
with a `code` parameter in the query string.
Just send that code to the `#access_token` method to complete the authorization
and get your `access_token` and `site_id`.

    # https://example.com/oauth?code=super_secret_temporary_code

    token = @auth.access_token(params[:code])

    token.access_token  # the token for the Client
    token.site_id      # the site_id for the Client

### Configure an new Client

A `Client` will interface with a single Weebly site. The `site_id` and OAuth
`access_token` will need to be provided to the client.

    require 'weebly_api'

    client = WeeblyApi::Client.new(site_id, access_token)

## The APIs

### Entities

Instead of returning raw JSON from the API, there are Entities that will help
you work with the data. The [Weebly API](http://api.weebly.com)
will give you all of the fields that are available for every entity. Our
Entities will give you access to the data with the `[]` method, or a snake_case
version of the property name. For example, with an `WeeblyApi::Category` the
following would be possible:

    order = client.orders.find(123)
    # An example response from the API
    # {
    #   "id": 123,
    #   "parentId": 456,
    #   "name": "Special Category"
    # }

    order[:id]          # Access with a Symbol
    # => 123

    order["parentId"]   # Access with a String (case sensitive)
    # => 456

    order.parent_id     # Access with a snake_case method
    # => 456


### Order API

The Order API will allow you to access the orders that have been placed in an
Weebly site. An instance of the Order API is available to the client

    api = client.orders

    api.all
    # Returns a `PagedEnumerator` containing all of the orders for the site

    api.all({date: "1982-05-17"})
    # Paremters can be passed as a Hash.
    # See http://kb.weebly.com/w/page/43697230/Order%20API#Parameters for
    # a list of available parameters

    api.find(123)
    # Returns an `WeeblyApi::Order` object for order 123

#### WeeblyApi::Order Entities

There are a few helper methods on the `WeeblyApi::Order` that assist in accessing
related Entities.

    order.items
    # Returns an Array of WeeblyApi::OrderItem objects

## Contributing

1. Fork it ( http://github.com/jamespeerless/weebly_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The MIT License (MIT)

Copyright (c) 2015 James Peerless

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

