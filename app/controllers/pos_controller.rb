class PosController < ApplicationController
  swagger_controller :pos, 'POS'

  swagger_api :get_menu do
    summary 'Get menu from pos system'
    param :query, :restaurant_id, :string, :required, "FoodApp restaurant id"
    response :forbidden
    response :ok
    response :unauthorized
  end

  def get_menu
    begin
      restaurant = Restaurant.find_by(foodapp_id: params[:restaurant_id])
    rescue
      render json: {errors: RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    menu = PosHelper::get_menu(restaurant)
    render json: menu, status: :ok
  end

  swagger_api :sync_menu do
    summary 'Sync menu with pos system'
    param :form, :restaurant_id, :string, :required, "FoodApp restaurant id"
    response :forbidden
    response :ok
    response :unauthorized
  end

  def sync_menu
    restaurant = Restaurant.find_by(foodapp_id: params[:restaurant_id])
    unless restaurant
      render json: {errors: :RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    PosHelper::sync_restaurant_menu(restaurant)
    render status: :ok
  end

  swagger_api :send_order do
    summary 'Send order to pos system'
    param :form, :restaurant_id, :string, :required, "FoodApp restaurant id"
    param :form, :order_id, :string, :required, "FoodApp order id"
    param :form, :customer_info, :string, :required, "Customer info {name: abc, phone: 79512341234}"
    param :form, :items, :string, :required, "Order items {id: FoodApp_id, amount: 10, sum: 20}"
    param :form, :payment_type, :string, :optional, ""
    response :forbidden
    response :ok
    response :unprocessable_entity
  end

  def send_order
    begin
      restaurant = Restaurant.find_by(foodapp_id: params[:restaurant_id])
    rescue
      render json: {errors: RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    order = PosHelper::send_order(
      restaurant, params[:customer_info].to_json, params[:items].to_json, params[:payment_type].to_json)

    unless order
      render json: {error: :ITEM_NOT_FOUNT}, status: :unprocessable_entity and return
    end

    if "error".in? order
      render json: order, status: :unprocessable_entity and return
    end

    new_order = Order.new(
      restaurant_id: restaurant.id,
      foodapp_order_id: params["order_id"],
      pos_order_id: order["orderId"],
      pos_order_number: order["number"]
    )
    if new_order.save
      render json: order, status: :ok
    else
      render json: new_order.errors, status: :unprocessable_entity
    end
  end

  swagger_api :check_order do
    summary 'Check order status'
    param :form, :restaurant_id, :string, :required, "FoodApp restaurant id"
    param :form, :order_id, :string, :required, "POS order uuid"
    response :forbidden
    response :ok
    response :unprocessable_entity
  end

  def check_order
    begin
      restaurant = Restaurant.find_by(foodapp_id: params[:restaurant_id])
    rescue
      render json: {errors: RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    begin
      order = restaurant.orders.find_by(foodapp_order_id: params[:order_id])
    rescue
      render json: {errors: ORDER_NOT_FOUND}, status: :forbidden and return
    end

    order_status_info = PosHelper::check_order(restaurant, order)

    unless order_status_info
      render json: {error: :ITEM_NOT_FOUNT}, status: :unprocessable_entity and return
    end

    if order_status_info
      foodapp_connection = FoodAppExchange.new(restaurant.user.email, nil)
      foodapp_order = foodapp_connection.update_order_status(
        order_status_info, restaurant.foodapp_id, order.foodapp_order_id)

      order.status = order_status_info[:status]

      render json: foodapp_order, status: :ok and return
    end

    render json: order_status_info, status: :ok
  end
end
