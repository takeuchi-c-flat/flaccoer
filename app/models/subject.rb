class Subject < ActiveRecord::Base
  self.table_name = 'subjects'

  belongs_to :fiscal_year
  belongs_to :subject_type
end
