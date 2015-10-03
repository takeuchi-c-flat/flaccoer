class SubjectTemplate < ActiveRecord::Base
  self.table_name = 'subject_templates'

  belongs_to :subject_template_type
  belongs_to :subject_type
end
