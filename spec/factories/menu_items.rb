FactoryBot.define do
  factory :menu_item do
    name { Faker::Lorem.word }
    price { Faker::Number.number(3) }
  end
end