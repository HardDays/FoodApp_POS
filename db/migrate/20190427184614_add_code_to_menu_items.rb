class AddCodeToMenuItems < ActiveRecord::Migration[5.2]
  def change
    add_column :menu_items, :code, :string
  end
end
