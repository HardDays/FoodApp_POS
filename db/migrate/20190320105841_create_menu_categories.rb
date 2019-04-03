class CreateMenuCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :menu_categories, id: :uuid do |t|
      t.string :name
      t.uuid :restaurant_id

      t.timestamps
    end
  end
end
