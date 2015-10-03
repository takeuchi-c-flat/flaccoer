FactoryGirl.define do
  factory :subject_type do
    account_type
    name '資産の部'
    short_name '資産'
    debit_and_credit_name '貸方科目'
    profit_and_loss_name '貸借勘定'
    debit true
    credit false
    debit_and_credit true
    profit_and_loss false
  end
end
