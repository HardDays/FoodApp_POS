class FoodAppController < ApplicationController
  swagger_controller :food_app, 'Food App'

  swagger_api :sign_in do
    summary 'Register user in the system'
    param :form, :email, :string, :required, 'Email'
    param :form, :password, :string, :required, 'Password'
    param :form, :restaurant_id, :string, :required, 'restaurant id'
    param_list :form, :pos_name, :string, :required, 'Pos system name', [:iiko, ]
    param :form, :pos_url, :string, :optional, 'Pos system url'
    param :form, :pos_login, :string, :optional, 'Pos system login'
    param :form, :pos_password, :string, :optional, 'Pos system pass'
    param :form, :sync_data, :boolean, :optional, 'syncronization required'
    param :form, :clear_menu, :boolean, :optional, 'clear menu before sync'
    response :ok
    response :unauthorized
  end

  def sign_in
    @connection = FoodAppExchange.new(params[:email], params[:password])
    @user = @connection.get_user

    unless @user
      render status: :unauthorized and return
    end

    local_user = User.where(email: @user["email"]).first
    unless local_user
      User.create(
        {
          id: @user["id"],
          email: @user["email"],
          first_name: @user["first_name"],
          last_name: @user["last_name"],
          phone: @user["phone"],
          token: @user["token"]
        })
    end

    @restaurant = PosHelper::connect_restaurant_to_pos(
      @connection, params[:restaurant_id],
      params[:pos_name], params[:pos_url], params[:pos_login], params[:pos_password])

    unless @restaurant
      render json: {errors: :RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    if params[:clear_menu]
      @connection.clear_menu(@restaurant.foodapp_id)
    end

    if params[:sync_data]
      sync_data
    end

    render status: :ok
  end

  def sync_data
    PosHelper.sync_restaurant_menu(@restaurant)
  end

  swagger_api :clear_menu do
    summary 'foodapp menu clear'
    response :ok
    response :unauthorized
  end

  def clear_menu
    @connection = FoodAppExchange.new("aaa@aaa.com", nil)
    @connection.clear_menu("1ff63949-2b03-4c15-917f-d74f0fc786b0")

    MenuCategory.destroy_all
    MenuItem.destroy_all

    render status: :ok
  end

  swagger_api :get_restaurant do
    summary 'foodapp restaurant'
    response :ok
    response :unauthorized
  end

  def get_restaurant
    @connection = FoodAppExchange.new("aaa@aaa.com", nil)
    restaurant = @connection.get_restaurant("1ff63949-2b03-4c15-917f-d74f0fc786b0")

    render json: restaurant, status: :ok
  end

  swagger_api :create_test_order do
    summary 'Create test order in foodapp'
    param :form, :date, :string, :required
    param :form, :item_id, :string, :required
    response :ok
    response :unauthorized
  end

  def create_test_order
    @connection = FoodAppExchange.new("aaa@aaa.com", nil)
    order = @connection.create_test_order(params[:date], params[:item_id])

    render json: order, status: :ok
  end

  swagger_api :get_orders do
    summary 'foodapp menu clear'
    response :ok
    response :unauthorized
  end

  def get_orders
    @connection = FoodAppExchange.new("aaa@aaa.com", nil)
    orders = @connection.get_orders

    render json: orders, status: :ok
  end
end
