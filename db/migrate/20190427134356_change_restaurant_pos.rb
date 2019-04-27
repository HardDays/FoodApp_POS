class ChangeRestaurantPos < ActiveRecord::Migration[5.2]
  def change
    rename_column :restaurants, :iiko_url, :pos_url
    rename_column :restaurants, :iiko_login, :pos_login
    rename_column :restaurants, :iiko_password, :pos_password

    add_column :restaurants, :pos_name, :integer
    add_column :restaurants, :pos_id, :uuid
    add_column :restaurants, :foodapp_id, :uuid
    add_column :restaurants, :currency, :string
  end
end
