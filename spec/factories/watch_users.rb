FactoryGirl.define do
  factory :watch_user do
    fiscal_year
    user
    can_modify false
  end
end
