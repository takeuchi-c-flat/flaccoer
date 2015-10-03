class SubjectTemplateType < ActiveRecord::Base
  self.table_name = 'subject_template_types'

  belongs_to :account_type
end
