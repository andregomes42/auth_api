FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    birthdate { Faker::Date.birthday }
    password { Faker::Internet.password(min_length: 8) }
  end

  trait :new do
    name { nil }
    email { nil }
    birthdate { nil }
    password { nil }
  end

  trait :invalid do
    email { Faker::Alphanumeric.alphanumeric }
    birthdate { Faker::Date.forward }
  end

  trait :short do 
    password { Faker::Internet.password(min_length: 2, max_length: 7) }
  end
end