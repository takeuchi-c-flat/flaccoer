FactoryGirl.define do
  factory :journal do
    fiscal_year
    journal_date Date.new(2015, 1, 1)
    subject_debit
    subject_credit
    price 10000
    comment '摘要'
  end
end
