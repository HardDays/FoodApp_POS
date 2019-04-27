class ChangeMenuIds < ActiveRecord::Migration[5.2]
  def change
    rename_column :menu_categories, :iiko_id, :pos_id
    rename_column :menu_items, :iiko_id, :pos_id
    rename_column :menu_items, :menu_category_id, :pos_menu_category_id

    add_column :menu_items, :foodapp_id, :uuid
    add_column :menu_items, :foodapp_menu_category_id, :uuid
    add_column :menu_categories, :foodapp_id, :uuid
  end
end
