class IIKOSync

  def self.upload_menu_categories(connection, restaurant)
    unless connection.is_a?(IIKOExchange)
      return nil
    end
    food_app_connection = FoodAppExchange.new(restaurant.user.email, nil)

    @menu_categories = JSON.parse connection.menu_categories
    @menu_categories.each do |iiko_menu_category|
      local_menu_category = MenuCategory.where(iiko_id: iiko_menu_category["id"]).first

      if local_menu_category
        food_app_connection.update_menu_category(iiko_menu_category.to_json, restaurant.id, local_menu_category.id)
      else
        new_menu_category = JSON.parse food_app_connection.set_menu_category(iiko_menu_category.to_json, restaurant.id)

        if new_menu_category
          MenuCategory.create(
            {
              id: new_menu_category["id"],
              name: new_menu_category["name"],
              iiko_id: iiko_menu_category["id"],
              restaurant_id: new_menu_category["restaurant_id"]
            })
        else
          print('category not saved')
        end
      end
    end
  end

  def self.upload_menu_items(connection, restaurant)
    unless connection.is_a?(IIKOExchange)
      return nil
    end
    food_app_connection = FoodAppExchange.new(restaurant.user.email, nil)

    @menu_categories = JSON.parse connection.menu_items
    @menu_categories.each do |iiko_menu_item|
      unless iiko_menu_item["defaultIncludedInMenu"]
        next
      end

      if iiko_menu_item["category"]
        local_menu_category = MenuCategory.where(iiko_id: iiko_menu_item["category"]).first
      else
        local_menu_category = MenuCategory.where(
          name: Rails.configuration.iiko_default_category,
          restaurant_id: restaurant.id
        ).first

        unless local_menu_category
          new_menu_category = JSON.parse food_app_connection.set_menu_category(
            {name: Rails.configuration.iiko_default_category}.to_json, restaurant.id)

          if new_menu_category
            local_menu_category = MenuCategory.create(
              {
                id: new_menu_category["id"],
                name: new_menu_category["name"],
                restaurant_id: new_menu_category["restaurant_id"]
              })
          else
            next
          end
        end
      end

      local_menu_item = MenuItem.where(iiko_id: iiko_menu_item["id"]).first
      if local_menu_item
        food_app_connection.update_menu_item(
          iiko_menu_item.to_json, restaurant.id, local_menu_category.id, local_menu_item.id)
      else
        iiko_menu_item["price"] = iiko_menu_item["defaultSalePrice"]
        new_menu_item = JSON.parse food_app_connection.set_menu_item(
          iiko_menu_item.to_json, restaurant.id, local_menu_category.id)

        if new_menu_item
          MenuItem.create(
            {
              id: new_menu_item["id"],
              name: new_menu_item["name"],
              description: new_menu_item["description"],
              menu_category_id: new_menu_item["menu_category_id"],
              price: new_menu_item["price"],
              cooking_time: new_menu_item["cooking_time"],
              kcal: new_menu_item["kcal"],
              restaurant_id: new_menu_item["restaurant_id"],
              currency: new_menu_item["currency"],
              iiko_id: iiko_menu_item["id"]
            })
        else
          print('item not saved')
        end
      end
    end
  end
end
