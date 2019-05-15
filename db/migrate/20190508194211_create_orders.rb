class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.uuid :restaurant_id
      t.uuid :pos_order_id

      t.timestamps
    end
  end
end
