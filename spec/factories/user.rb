FactoryBot.define do
  # cheat sheet: https://devhints.io/factory_bot

  factory :user do
    name { Faker::Name.name }

    sequence :user_name do |n|
      # some hipster words have "-'&" (╯°□°)╯︵ ┻━┻
      # https://github.com/faker-ruby/faker/blob/master/doc/default/hipster.md
      # https://github.com/faker-ruby/faker/blob/master/lib/locales/en/hipster.yml
      "#{Faker::Hipster.word.gsub(/[^0-9A-Za-z]/, '')}_#{n}"
    end

    sequence :email do |n|
      "person#{n}@example.com"
    end

    password { 'password' }

    # user must confirm their account before signing in
    trait :confirmed do
      before :create do |user|
        user.confirmed_at = Time.now.utc
      end
    end
  end
end
