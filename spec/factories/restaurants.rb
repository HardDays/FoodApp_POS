FactoryBot.define do
  factory :restaurant do
    name { Faker::Lorem.word }
    association :user
  end
end