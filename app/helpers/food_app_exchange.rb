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

  def get_restaurant(restaurant_id)
    restaurant = self.class.get(
        "/restaurants/#{restaurant_id}",
        headers: {
            'Content-Type' => 'application/json',
            'Authorization' => @user["token"]
        }
    ).body

    if restaurant == ""
      restaurant = "{}"
    end

    JSON.parse restaurant
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

    print(menu_category)
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

  def clear_menu(restaurant_id)
    restaurant = self.class.get(
      "/restaurants/#{restaurant_id}",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if restaurant == ""
      restaurant = "{}"
    end

    restaurant = JSON.parse restaurant

    restaurant["menu_categories"].each do |menu_category|
      menu_category["menu_items"].each do |menu_item|
        self.class.delete(
          "/restaurants/#{restaurant_id}/menu_categories/#{menu_category["id"]}/menu_items/#{menu_item["id"]}",
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => @user["token"]
          }
        )
      end

      self.class.delete(
        "/restaurants/#{restaurant_id}/menu_categories/#{menu_category["id"]}",
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => @user["token"]
        }
      )
    end
  end

  def create_test_order(date, item_id)
    item = MenuItem.find_by(pos_id: "bb0f7fae-e90b-4629-0169-9ae9ca3602fd")

    order = self.class.post(
      "/users/me/orders",
      body: {
        "date": date,
        "people_count": 1,
        "carry_option": "with_me",
        "order_menu_items": [
          {
            "menu_item_id": item_id,
            "count": 1
          }
        ]
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    )
    order = order.body

    if order == ""
      order = "{}"
    end

    JSON.parse order
  end

  def update_order_status(json, restaurant_id, order_id)
     order = self.class.put(
      "/restaurants/#{restaurant_id}/orders/#{order_id}",
      body: json.to_json,
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

  def get_orders
    orders = self.class.get(
      "/users/me/orders/current",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => @user["token"]
      }
    ).body

    if orders == ""
      orders = "{}"
    end

    JSON.parse orders
  end
end
