class AddIikoParamsToRestaurant < ActiveRecord::Migration[5.2]
  def change

    remove_column :users, :iiko_url, :string
    remove_column :users, :iiko_login, :string
    remove_column :users, :iiko_password, :string

    add_column :restaurants, :iiko_url, :string
    add_column :restaurants, :iiko_login, :string
    add_column :restaurants, :iiko_password, :string
  end
end
