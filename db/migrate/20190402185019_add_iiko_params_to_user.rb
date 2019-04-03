class AddIikoParamsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :iiko_url, :string
    add_column :users, :iiko_login, :string
    add_column :users, :iiko_password, :string
  end
end
