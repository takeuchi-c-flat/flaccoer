FactoryGirl.define do
  factory :subject_credit, class: Subject do
    fiscal_year
    subject_type
    code '001'
    name '科目名１'
  end
end
