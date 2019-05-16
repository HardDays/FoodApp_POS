class Order < ApplicationRecord
  validates_presence_of :restaurant_id
  validates_presence_of :pos_order_id
  validates_presence_of :foodapp_order_id

  enum status: [:added, :in_progress, :ready, :canceled]

  belongs_to :restaurant
end
