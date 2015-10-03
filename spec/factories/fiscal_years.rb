FactoryGirl.define do
  factory :fiscal_year do
    user
    account_type
    subject_template_type
    title 'タイトル'
    organization_name '組織名'
    date_from Date.new(2015, 1, 1)
    date_to Date.new(2015, 12, 31)
    locked false
  end
end
