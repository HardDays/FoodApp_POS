class AddFoodappOrderIdToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :foodapp_order_id, :uuid
  end
end
