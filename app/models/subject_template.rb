class SubjectTemplate < ActiveRecord::Base
  self.table_name = 'subject_templates'

  belongs_to :subject_template_type
  belongs_to :subject_type

  def get_report_locations
    [report1_location, report2_location, report3_location, report4_location, report5_location]
  end
end
