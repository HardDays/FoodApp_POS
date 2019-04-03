require 'rails_helper'

RSpec.describe MenuCategory, type: :model do
  it { should validate_presence_of(:name) }

  it { should have_many(:menu_items)}

  it { should belong_to(:restaurant) }
  it "should be deleted when delete restaurant" do
    user = create(:user)
    restaurant = create(:restaurant, user_id: user.id)
    menu_category = create(:menu_category, restaurant_id: restaurant.id)

    expect { restaurant.destroy }.to change { MenuCategory.count }.by(-1)
  end
end
