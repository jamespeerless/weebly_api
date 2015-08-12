module WeeblyApi
  # Public: This is an Weebly Order
  class Order < Entity
    self.url_root = "/store/orders"

    attr_reader :user_id, :site_id, :order_id, :full_name,
      :status, :currency, :total, :tax_total, :order_tax_total,
      :shipping_method, :subtotal, :total
 
    VALID_FULFILLMENT_STATUSES = %w(
      AWAITING_PROCESSING
      PROCESSING
      SHIPPED
      DELIVERED
      WILL_NOT_DELIVER
      RETURNED
    )

    # Public: Gets the unique ID of the order
    def id
      order_id
    end

    # Public: Returns the billing person
    def billing_person
      return unless data["billingPerson"] || data["shippingPerson"]

      @billing_person ||= if data["billingPerson"]
        Person.new(data["billingPerson"])
      else
        shipping_person
      end
    end

    # Public: Returns the shipping person
    def shipping_person
      return unless data["shippingPerson"] || data["billingPerson"]
      @shipping_person ||= if data["shippingPerson"]
        Person.new(data["shippingPerson"])
      else
        billing_person
      end
    end

    # Public: Returns a Array of `OrderItem` objects
    def items
      @items ||= data["items"].map { |item| OrderItem.new(item) }
    end

    def fulfillment_status=(status)
      status = status.to_s.upcase
      unless VALID_FULFILLMENT_STATUSES.include?(status)
        raise Error("#{status} is an invalid fullfillment status")
      end
      super(status)
    end

    def fulfillment_status
      super && super.downcase.to_sym
    end
  end
end