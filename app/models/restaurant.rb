class Restaurant < ApplicationRecord
  validates_presence_of :name

  enum pos_name: [:rkeeper, :iiko]

  belongs_to :user

  has_many :menu_categories, dependent: :destroy
  has_many :menu_items, dependent: :destroy
end
