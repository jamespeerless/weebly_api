module WeeblyApi
  # Public: This is an Weebly Product
  class Product < Entity
    self.url_root = "/store/products"

    attr_reader :user_id, :site_id, :product_id, :name,
      :published, :price_low, :price_high, :sale_price_low, :sale_price_high,
      :inventory
 
    # Public: Gets the unique ID of the product
    def id
      product_id
    end
   
  end
end