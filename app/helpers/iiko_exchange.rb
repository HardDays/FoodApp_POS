class IIKOExchange
  include HTTParty
  base_uri 'https://iiko.biz:9900/api/0'

  @@order_statuses = {
    "Готовится": :in_process,
    "In progress": :in_process,
    "Не подтверждена": :in_process,
    "Not confirmed": :in_process,
    "Ждет отправки": :ready,
    "Awaiting delivery": :ready,
    "В пути": :ready,
    "On the way": :ready,
    "Закрыта": :ready,
    "Closed": :ready,
    "Доставлена": :ready,
    "Delivered": :ready,
    "Готово": :ready,
    "Ready": :ready,
    "Отменена": :canceled_resto,
    "Cancelled": :canceled_resto,
  }

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
    payment_type = {
      id: "09322f46-578a-d210-add7-eec222a08871",
      code: "CASH",
      name: "Наличные",
      comment: nil,
      combinable: true,
      externalRevision: 0,
      applicableMarketingCampaigns: nil,
      deleted: false
    }

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

    begin
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
      ).body
    rescue
      return JSON.parse '{"error": "can\'t send order to POS system"}'
    end

    if order == ""
      order = "{}"
    end

    JSON.parse order
  end

  def check_order(restaurant, order)
    order_info = self.class.get(
      "/orders/info?access_token=#{@token}&organization=#{restaurant.pos_id}&order=#{order.pos_order_id}",
      headers: {
        'Content-Type' => 'application/json'
      }
    ).body

    result = {}
    if order_info
      order_info = JSON.parse order_info

      if order_info["status"].to_sym.in? @@order_statuses.keys
        result = {
          order_status: @@order_statuses[order_info["status"].to_sym]
        }
      end
    end

    result.to_json
  end
end
