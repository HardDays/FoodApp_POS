class MenuCategory < ApplicationRecord
  validates_presence_of :name

  belongs_to :restaurant

  has_many :menu_items, dependent: :destroy
end
