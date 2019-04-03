require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:price) }

  it { should belong_to(:restaurant) }
  it "should be deleted when delete restaurant" do
    user = create(:user)
    restaurant = create(:restaurant, user_id: user.id)
    menu_category = create(:menu_category, restaurant_id: restaurant.id)
    menu_item = create(:menu_item, restaurant_id: restaurant.id, menu_category_id: menu_category.id)

    expect { restaurant.destroy }.to change { MenuItem.count }.by(-1)
  end

  it { should belong_to(:menu_category) }
  it "should be deleted when delete menu catefory" do
    user = create(:user)
    restaurant = create(:restaurant, user_id: user.id)
    menu_category = create(:menu_category, restaurant_id: restaurant.id)
    menu_item = create(:menu_item, restaurant_id: restaurant.id, menu_category_id: menu_category.id)

    expect { menu_category.destroy }.to change { MenuItem.count }.by(-1)
  end
end
