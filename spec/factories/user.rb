FactoryBot.define do
  # cheat sheet: https://devhints.io/factory_bot

  factory :user do
    name { Faker::Name.name }
    user_name { "#{Faker::Hipster.word}#{Faker::Number.number(digits: 4)}" }
    email { Faker::Internet.email }
    password { 'password' }

    # user must confirm their account before signing in
    trait :confirmed do
      before :create do |user|
        user.confirmed_at = Time.now.utc
      end
    end
  end
end
