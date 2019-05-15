class FoodAppExchange
  include HTTParty
  base_uri ENV['foodapp_url']

  def initialize(email, password)
    @user = User.where(email: email).first
    if @user
      @token = @user.token
      @user = @user.as_json
    elsif password

      response = self.class.post(
        "/auth/login",
        body: {
          "email" => email,
          "password" => password
        }.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      )

      if response.code == 200
        @user = JSON.parse response.body
        @token = @user["token"]
      end
    end

    unless @user
      @user= nil
    end

    @user
  end

  def get_user
    @user
  end

  def get_user_id
    @user["id"]
  end

  def restaurants
    restaurants = self.class.get(
        "/users/me/restaurants",
        headers: {
            'Content-Type' => 'application/json',
            'Authorization' => @user["token"]
        }
    ).body

    if restaurants == ""
      restaurants = "{}"
    end

    JSON.parse restaurants
  end

  def get_menu_categories(restaurant_id)
    menu_categories = self.class.get(
      "/restaurants/#{restaurant_id}/menu_categories",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if menu_categories == ""
      menu_categories = "{}"
    end

    JSON.parse menu_categories
  end

  def set_menu_category(json, restaurant_id)
    menu_category = self.class.post(
      "/restaurants/#{restaurant_id}/menu_categories",
      body: json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if menu_category == ""
      menu_category = "{}"
    end

    JSON.parse menu_category
  end

  def update_menu_category(json, restaurant_id, menu_category_id)
    menu_category = self.class.put(
      "/restaurants/#{restaurant_id}/menu_categories/#{menu_category_id}",
      body: json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if menu_category == ""
      menu_category = "{}"
    end

    JSON.parse menu_category
  end

  def get_menu_items(restaurant_id, menu_category_id)
    menu_items = self.class.get(
      "/restaurants/#{restaurant_id}/menu_categories/#{menu_category_id}/menu_items",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if menu_items == ""
      menu_items = "{}"
    end

    JSON.parse menu_items
  end

  def set_menu_item(json, restaurant_id, menu_category_id)
    menu_item = self.class.post(
      "/restaurants/#{restaurant_id}/menu_categories/#{menu_category_id}/menu_items",
      body: json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if menu_item == ""
      menu_item = "{}"
    end

    JSON.parse menu_item
  end

  def update_menu_item(json, restaurant_id, menu_category_id, menu_item_id)
    menu_item = self.class.put(
      "/restaurants/#{restaurant_id}/menu_categories/#{menu_category_id}/menu_items/#{menu_item_id}",
      body: json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if menu_item == ""
      menu_item = "{}"
    end

    JSON.parse menu_item
  end

  def update_order_status(json, restaurant_id, order_id)
     order = self.class.put(
      "/restaurants/#{restaurant_id}/orders/#{order_id}",
      body: json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if order == ""
      order = "{}"
    end

    JSON.parse order
  end
end
