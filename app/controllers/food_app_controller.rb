class FoodAppController < ApplicationController
  swagger_controller :food_app, 'Food App'

  swagger_api :sign_in do
    summary 'Register user in the system'
    param :form, :email, :string, :required, 'Email'
    param :form, :password, :string, :required, 'Password'
    param :form, :restaurant_id, :string, :required, 'restaurant id'
    param :form, :iiko_url, :string, :optional, 'iiko url'
    param :form, :iiko_login, :string, :optional, 'iiko login'
    param :form, :iiko_password, :string, :optional, 'iiko pass'
    param :form, :sync_data, :boolean, :optional, 'syncronization required'
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

    iiko_pass_hash = Digest::SHA1.hexdigest(params[:iiko_password])
    restaurant_connected = FoodAppSync.connect_restaurant_to_iiko(
      @connection, params[:restaurant_id], params[:iiko_url], params[:iiko_login], iiko_pass_hash)

    unless restaurant_connected
      render json: {errors: :RESTAURANT_NOT_FOUND}, status: :forbidden and return
    end

    if params[:sync_data]
      sync_data
    end

    render status: :ok
  end

  def sync_data
    FoodAppSync.sync_restaurant_menu(params[:restaurant_id])
  end
end
