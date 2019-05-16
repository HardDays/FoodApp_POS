namespace :orders do
  desc "TODO"
  task update_order_status: :environment do
    orders = Order.where(status: [Order.statuses[:added], Order.statuses[:in_progress]])

    orders.each do |order|
      order_status_info = PosHelper::check_order(order.restaurant, order)

      unless order_status_info
        print("status info not fount fo order #{order.pos_order_number}")
      end
      print(order_status_info)

      if order_status_info
        foodapp_connection = FoodAppExchange.new(order.restaurant.user.email, nil)
        foodapp_order = foodapp_connection.update_order_status(
          order_status_info, order.restaurant.foodapp_id, order.foodapp_order_id)

        if foodapp_order
          order.status = order_status_info[:status]
        end

        print("#{order.pos_order_number} ok")
      end
    end
  end

end
