FactoryGirl.define do
  factory :subject_debit, class: Subject do
    fiscal_year
    subject_type
    code '002'
    name '科目名２'
  end
end
