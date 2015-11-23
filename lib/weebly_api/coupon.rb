module WeeblyApi
  # Public: This is an Weebly Coupon
  class Coupon < Entity
    self.url_root = "/store/coupons"

    attr_reader :user_id, :site_id, :coupon_id, :code, :type, :amount,
      :start_date, :end_date, :criteria, :criteria_amount, :num_available, 
      :num_used
   
  end
end