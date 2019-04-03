class AddIikoIdsToCategoryAndItem < ActiveRecord::Migration[5.2]
  def change
    add_column :menu_items, :iiko_id, :uuid
    add_column :menu_categories, :iiko_id, :uuid
  end
end
