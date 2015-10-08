class SubjectType < ActiveRecord::Base
  self.table_name = 'subject_types'

  belongs_to :account_type

  def self.debit_only
    where(debit: true)
  end

  def self.credit_only
    where(credit: true)
  end

  def self.debit_and_credit_only
    where(debit_and_credit: true)
  end

  def self.profit_and_loss_only
    where(profit_and_loss: true)
  end
end
