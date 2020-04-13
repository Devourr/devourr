FactoryBot.define do
  factory :blocked_user_name do
    sequence :user_name do |n|
      "blocked._#{n}"
    end
  end
end
