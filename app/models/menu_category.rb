class MenuCategory < ApplicationRecord
  validates_presence_of :name

  belongs_to :restaurant
end
