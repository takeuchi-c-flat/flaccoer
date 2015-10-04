class Balance < ActiveRecord::Base
  self.table_name = 'balances'

  belongs_to :fiscal_year
  belongs_to :subject
end
