class IikoController < ApplicationController
  swagger_controller :iiko, 'IIKO'

  swagger_api :get_menu do
    summary 'Get menu from iiko'
    param :query, :restaurant_id, :string, :required, "Restaurant id"
    response :forbidden
    response :ok
    response :unauthorized
  end

  def get_menu
    restaurant = Restaurant.where(id: params[:restaurant_id]).first

    unless restaurant
      render json: {errors: RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    iiko_conection = IIKOExchange.new(restaurant)
    menu_items = JSON.parse iiko_conection.menu_items
    render json: menu_items, status: :ok
  end

  swagger_api :sync_menu do
    summary 'Upload menu from iiko'
    param :form, :restaurant_id, :string, :required, "Restaurant id"
    response :forbidden
    response :ok
    response :unauthorized
  end

  def sync_menu
    restaurant = Restaurant.where(id: params[:restaurant_id]).first

    unless restaurant
      render json: {errors: RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    iiko_conection = IIKOExchange.new(restaurant)
    IIKOSync.upload_menu_categories(iiko_conection, restaurant)
    IIKOSync.upload_menu_items(iiko_conection, restaurant)
  end
end
