class PosHelper
  @@pos_systems = {iiko: IIKOExchange}

  def self.set_connection(restaurant)
    @connection = @@pos_systems[restaurant.pos_name.to_sym].new(restaurant)

    unless restaurant.pos_id
      id_set = @connection.set_restaurant_pos_info(restaurant)

      unless id_set
        return :POS_ID_NOT_SET
      end
    end

    true
  end

  def self.get_menu(restaurant)
    self.set_connection(restaurant)
    menu = @connection.get_menu(restaurant.pos_id)
    menu
  end

  def self.download_menu(restaurant)
    @menu = @connection.get_menu(restaurant.pos_id)

    @menu["productCategories"].each do |menu_category|

      MenuCategory.where(pos_id: menu_category["id"],
                         restaurant_id: restaurant.id).first_or_initialize.tap do |local_category|
        local_category.name = menu_category["name"]
        local_category.save
      end
    end

    @menu["products"].each do |menu_item|

      MenuItem.where(pos_id: menu_item["id"],
                     pos_menu_category_id: menu_item["pos_category_id"],
                     restaurant_id: restaurant.id).first_or_initialize.tap do |local_menu_item|
        local_menu_item.name = menu_item["name"]
        local_menu_item.code = menu_item["code"]
        local_menu_item.description = menu_item["description"]
        local_menu_item.price = menu_item["price"] * 100
        local_menu_item.cooking_time = menu_item["cooking_time"]
        local_menu_item.kcal = menu_item["kcal"]
        local_menu_item.currency = restaurant.currency
        local_menu_item.save
      end
    end
  end

  def self.upload_menu_categories(restaurant)
    food_app_connection = FoodAppExchange.new(restaurant.user.email, nil)

    MenuCategory.where(updated_at: (DateTime.now - 1.day)..DateTime.now).each do |local_menu_category|

      if local_menu_category.foodapp_id
        food_app_connection.update_menu_category(
          local_menu_category.to_json, restaurant.foodapp_id, local_menu_category.foodapp_id)
      else
        new_menu_category = food_app_connection.set_menu_category(local_menu_category.to_json, restaurant.foodapp_id)
        local_menu_category.foodapp_id = new_menu_category["id"]
        local_menu_category.save
      end
    end
  end

  def self.upload_menu_items(restaurant)
    food_app_connection = FoodAppExchange.new(restaurant.user.email, nil)

    MenuItem.where(updated_at: (DateTime.now - 1.day)..DateTime.now).each do |local_menu_item|

      if local_menu_item.pos_menu_category_id
        local_menu_category = MenuCategory.find_by(pos_id: local_menu_item.pos_menu_category_id)

        unless local_menu_category.foodapp_id
          self.upload_menu_items(restaurant)
          local_menu_category = MenuCategory.find_by(pos_id: local_menu_item.pos_menu_category_id)
        end
      else
        local_menu_category = MenuCategory.where(
          name: Rails.configuration.default_category_name,
          restaurant_id: restaurant.id
        ).first

        unless local_menu_category
          new_menu_category = food_app_connection.set_menu_category(
            {name: Rails.configuration.default_category_name}.to_json, restaurant.foodapp_id)

          if new_menu_category
            local_menu_category = MenuCategory.create(
              {
                foodapp_id: new_menu_category["id"],
                name: new_menu_category["name"],
                restaurant_id: new_menu_category["restaurant_id"]
              })
          else
            next
          end
        end

        unless local_menu_category.foodapp_id
          new_menu_category = food_app_connection.set_menu_category(
            {name: Rails.configuration.default_category_name}.to_json, restaurant.foodapp_id)

          if new_menu_category
            local_menu_category.foodapp_id = new_menu_category["id"]
            local_menu_category.save
          else
            next
          end
        end
      end

      if local_menu_item.foodapp_id
        food_app_connection.update_menu_item(
          local_menu_item.to_json, restaurant.foodapp_id, local_menu_category.foodapp_id, local_menu_item.foodapp_id)
      else
        new_menu_item = food_app_connection.set_menu_item(
          local_menu_item.to_json, restaurant.foodapp_id, local_menu_category.foodapp_id)
        local_menu_item.foodapp_id = new_menu_item["id"]
        local_menu_item.foodapp_menu_category_id = new_menu_item["menu_category_id"]
        local_menu_item.save
      end
    end
  end

  def self.sync_restaurant_menu(restaurant)
    self.set_connection(restaurant)

    self.download_menu(restaurant)
    self.upload_menu_categories(restaurant)
    self.upload_menu_items(restaurant)
  end

  def self.connect_restaurant_to_pos(connection, restaurant_id, pos_name, pos_url, pos_login, pos_password)
    unless connection.is_a?(FoodAppExchange)
      return nil
    end

    restaurant = nil

    @restaurants = connection.restaurants
    @restaurants.each do |foodapp_restaurant|

      if foodapp_restaurant["id"] == restaurant_id
        Restaurant.where(foodapp_id: foodapp_restaurant["id"],
                         user_id: connection.get_user_id).first_or_initialize.tap do |local_restaurant|
          local_restaurant.name = foodapp_restaurant["name"]
          local_restaurant.address = foodapp_restaurant["address"]
          local_restaurant.user_id = connection.get_user_id
          local_restaurant.pos_name = Restaurant.pos_names[pos_name]
          local_restaurant.pos_login = pos_login
          local_restaurant.pos_password = pos_password
          local_restaurant.save
          restaurant = local_restaurant
        end
      end
    end

    restaurant
  end

  def self.send_order(restaurant, customer_info, items, payment_type)
    self.set_connection(restaurant)

    items = JSON.parse items
    customer_info = JSON.parse customer_info
    payment_type = JSON.parse payment_type

    items.each do |item|
      local_menu_item = MenuItem.find_by(foodapp_id: item["id"])

      unless local_menu_item
        return false
      end

      item["id"] = local_menu_item.pos_id
      item["name"] = local_menu_item.name
      item["code"] = local_menu_item.code
    end

    @connection.send_order(restaurant.pos_id, customer_info, items, payment_type)
  end

  def self.check_order(restaurant, order)
    self.set_connection(restaurant)

    @connection.check_order(restaurant, order)
  end
end
