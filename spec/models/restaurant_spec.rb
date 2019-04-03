require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  it { should validate_presence_of(:name) }

  it { should have_many(:menu_categories) }

  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    restaurant = create(:restaurant, user_id: user.id)

    expect { user.destroy }.to change { Restaurant.count }.by(-1)
  end
end
