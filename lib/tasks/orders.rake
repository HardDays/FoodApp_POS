namespace :orders do
  desc "TODO"
  task update_order_status: :environment do
    orders = Order.where(status: [Order.statuses[:added], Order.statuses[:in_progress], nil])

    orders.each do |order|
      order_status_info = PosHelper::check_order(order.restaurant, order)

      unless order_status_info
        print("status info not fount fo order #{order.pos_order_number}")
      end

      order_status_info = JSON.parse order_status_info
      print(order_status_info)

      if "order_status".in? order_status_info
        foodapp_connection = FoodAppExchange.new(order.restaurant.user.email, nil)
        foodapp_order = foodapp_connection.update_order_status(
          order_status_info, order.restaurant.foodapp_id, order.foodapp_order_id)

        print(foodapp_order)
        print(order.restaurant.foodapp_id)
        print(order.foodapp_order_id)
        if foodapp_order
          order.status = order_status_info[:status]
          order.save
        end

        print("#{order.pos_order_number} ok")
      end

      print("\n")
      print("\n")
      print("\n")
    end
  end

end
