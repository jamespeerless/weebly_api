module WeeblyApi
  class Entity
    include Api

    # Private: Gets the Hash of data
    attr_reader :data
    protected   :data

    class << self
      attr_accessor :url_root
    end

    # Public: Initialize a new entity with a reference to the client and data
    #
    # data   - A Hash of data that represents the properties of this Entity
    # opts   - A Hash of options
    #          :client - The WeeblyApi::Client creating the Entity
    #
    def initialize(data, opts={})
      @client, @data = opts[:client], data
      @new_data = {}
    end

    # Public: Returns a property of the data (actual property name)
    #
    # key - A Symbol or String of the property. The key should be the actual
    #       key according to the Weebly API documentation for the given entity.
    #       Typically, this is camel cased.
    #
    # Examples
    #
    #   entity[:parentId]
    #   entity["parentId"]
    #
    # Returns the value of the property, or nil if it doesn't exist
    def [](key)
      @new_data[key.to_s] || data[key.to_s]
    end

    # Public: The URL of the entity
    #
    # Returns a String that is the URL of the entity
    def url
      url_root = self.class.url_root
      raise Error.new("Please specify a url_root for the #{self.class.to_s}") unless url_root

      if url_root.respond_to?(:call)
        url_root = instance_exec(&url_root)
      end

      url_root + "/#{id}"
    end

    def assign_attributes(attributes)
      attributes.each do |key, val|
        send("#{key}=", val)
      end
    end

    def assign_raw_attributes(attributes)
      attributes.each do |key, val|
        @new_data[key.to_s] = val
      end
    end

    def update_attributes(attributes)
      assign_attributes(attributes)
      save
    end

    def update_raw_attributes(attributes)
      assign_raw_attributes(attributes)
      save
    end

    # Public: Saves the Entity
    #
    # Saves anything stored in the @new_data hash
    #
    # path - the URL of the entity
    #
    def save
      unless @new_data.empty?
        client.put(url, @new_data).tap do |response|
          raise_on_failure(response)
          @data.merge!(@new_data)
          @new_data.clear
        end
      end
    end

    # Public: Destroys the Entity
    def destroy!
      client.delete(url).tap do |response|
        raise_on_failure(response)
      end
    end

    def to_hash
      data
    end

    def to_json(*args)
      data.to_json(*args)
    end
  end
end