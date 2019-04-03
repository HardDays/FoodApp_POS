require "rails_helper"

RSpec.describe FoodAppController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users").to route_to("food_app#index")
    end

    it "routes to #show" do
      expect(:get => "/users/1").to route_to("food_app#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/users").to route_to("food_app#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1").to route_to("food_app#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1").to route_to("food_app#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1").to route_to("food_app#destroy", :id => "1")
    end
  end
end
