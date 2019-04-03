class ChangeCurrencyToMenuItems < ActiveRecord::Migration[5.2]
  def change
    change_column :menu_items, :currency, :string
  end
end
