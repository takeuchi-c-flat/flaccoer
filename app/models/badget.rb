class Badget < ActiveRecord::Base
  self.table_name = 'badgets'

  belongs_to :fiscal_year
  belongs_to :subject
end
