class AddPosOrderNumberToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :pos_order_number, :integer
  end
end
