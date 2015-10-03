class SubjectType < ActiveRecord::Base
  self.table_name = 'subject_types'

  belongs_to :account_type
end
