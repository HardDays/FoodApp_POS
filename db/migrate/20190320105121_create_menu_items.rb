class CreateMenuItems < ActiveRecord::Migration[5.2]
  def change
    create_table :menu_items, id: :uuid do |t|
      t.string :name
      t.string :description
      t.uuid :menu_category_id
      t.integer :price
      t.integer :cooking_time
      t.integer :kcal
      t.uuid :restaurant_id
      t.integer :currency

      t.timestamps
    end
  end
end
