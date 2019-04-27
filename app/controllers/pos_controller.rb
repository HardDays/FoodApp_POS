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
    begin
      restaurant = Restaurant.find_by(foodapp_id: params[:restaurant_id])
    rescue
      render json: {errors: RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    PosHelper::sync_restaurant_menu(restaurant)
    render status: :ok
  end

  swagger_api :send_order do
    summary 'Send order to pos system'
    param :form, :restaurant_id, :string, :required, "FoodApp restaurant id"
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

    result = PosHelper::send_order(
      restaurant, params[:customer_info].to_json, params[:items].to_json, params[:payment_type].to_json)

    unless result
      render json: {error: :ITEM_NOT_FOUNT}, status: :unprocessable_entity and return
    end

    render json: result, status: :ok
  end
end
