class FoodAppSync

  def self.connect_restaurant_to_iiko(connection, restaurant_id, iiko_url, iiko_login, iiko_hash)
    unless connection.is_a?(FoodAppExchange)
      return nil
    end

    restaurant_found = false

    @restaurants = JSON.parse connection.restaurants
    @restaurants.each do |restaurant|

      if restaurant["id"] == restaurant_id
        restaurant_found = true

        Restaurant.where(
          id: restaurant["id"], user_id: connection.get_user_id).first_or_initialize.tap do |local_restaurant|
          local_restaurant.name = restaurant["name"]
          local_restaurant.address = restaurant["address"]
          local_restaurant.user_id = connection.get_user_id
          local_restaurant.iiko_url = iiko_url
          local_restaurant.iiko_login = iiko_login
          local_restaurant.iiko_password = iiko_hash
          local_restaurant.save
        end
      end
    end

    restaurant_found
  end

  def self.get_menu_items(connection, restaurant_id, menu_category_id)
    unless connection.is_a?(FoodAppExchange)
      return nil
    end

    @menu_items = JSON.parse connection.get_menu_items(restaurant_id, menu_category_id)
    @menu_items.each do |menu_item|

      MenuItem.where(id: menu_item["id"],
                     menu_category_id: menu_item["menu_category_id"],
                     restaurant_id: menu_item["restaurant_id"]).first_or_initialize.tap do |local_menu_item|
        local_menu_item.name = menu_item["name"]
        local_menu_item.description = menu_item["description"]
        local_menu_item.price = menu_item["price"]
        local_menu_item.cooking_time = menu_item["cooking_time"]
        local_menu_item.kcal = menu_item["kcal"]
        local_menu_item.currency = menu_item["currency"]
        local_menu_item.save
      end
    end
  end

  def self.get_menu_categories(connection, restaurant_id, include_items)
    unless connection.is_a?(FoodAppExchange)
      return nil
    end

    @menu_categories = JSON.parse connection.get_menu_categories(restaurant_id)
    @menu_categories.each do |menu_category|

      MenuCategory.where(id: menu_category["id"],
                         restaurant_id: menu_category["restaurant_id"]).first_or_initialize.tap do |local_category|
        local_category.name = menu_category["name"]
        local_category.save
      end

      if include_items
        self.get_menu_items(connection, restaurant_id, menu_category["id"])
      end
    end
  end

  def self.sync_restaurant_menu(restaurant_id)
    restaurant = Restaurant.where(id: restaurant_id).first
    unless restaurant
      return
    end

    connection = FoodAppExchange.new(restaurant.user.email, nil)
    self.get_menu_categories(connection, restaurant_id, true)
  end
end
