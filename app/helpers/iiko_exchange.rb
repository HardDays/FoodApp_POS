class IIKOExchange
  include HTTParty
  base_uri 'https://iiko.biz:9900/api/0'

  def initialize(restaurant)
    response = self.class.get(
      "/auth/access_token?user_id=#{restaurant.pos_login}&user_secret=#{restaurant.pos_password}",
      headers: {
        'Content-Type' => 'application/json'
      }
    )

    if response.code == 200
      @token = response.body.gsub('"', '')
    end
  end

  def set_restaurant_pos_info(restaurant)
    restaurants = self.class.get(
      "/organization/list?access_token=#{@token}",
      headers: {
        'Content-Type' => 'application/json'
      }
    ).body

    if restaurants == ""
      return false
    end

    restaurants = JSON.parse restaurants
    restaurant.pos_id = restaurants[0]["id"]
    restaurant.currency = restaurants[0]["currencyIsoName"]
    restaurant.save
    true
  end

  def get_menu(restaurant_guid)
    menu_items = self.class.get(
      "/nomenclature/#{restaurant_guid}?access_token=#{@token}",
      headers: {
        'Content-Type' => 'application/json'
      }
    ).body

    if menu_items == ""
      menu_items = "{}"
    end

    menu_items = JSON.parse menu_items
    menu_items["products"].each do |menu_item|
      menu_item["pos_category_id"] = menu_item["productCategoryId"]
      menu_item["cooking_time"] = nil
      menu_item["kcal"] = menu_item["energyFullAmount"]
    end

    menu_items
  end

  def send_order(restaurant_guid, customer_info, items, payment_type)
    items_data = []
    items.each do |item|
      items_data.append(
        {
          id: item["id"],
          name: item["name"],
          amount: item["amount"],
          code: item["code"],
          sum: item["sum"]
        })
    end

    order = self.class.post(
      "/orders/add?&access_token=#{@token}",
      body: {
        organization: restaurant_guid,
        customer: {
          name: customer_info["name"],
          phone: customer_info["phone"]
        },
        order: {
          date: DateTime.now,
          phone: customer_info["phone"],
          isSelfService: true,
          items: items_data
        },
        address: {},
        paymentItems: [
          {
            sum: 0,
            paymentType: [payment_type],
            isProcessedExternally: false
          }
        ]
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    )

    order
  end
end
