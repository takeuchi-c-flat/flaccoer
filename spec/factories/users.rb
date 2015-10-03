FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "User#{n}@example.local" }
    name 'テストユーザ名'
    password 'password'
    suspended false
    admin_user false
  end
end
