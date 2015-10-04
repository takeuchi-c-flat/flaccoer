class Subject < ActiveRecord::Base
  self.table_name = 'subjects'

  belongs_to :fiscal_year
  belongs_to :subject_type

  def get_report_locations
    [report1_location, report2_location, report3_location, report4_location, report5_location]
  end

  def set_report_locations(locations)
    self.report1_location = locations[0]
    self.report2_location = locations[1]
    self.report3_location = locations[2]
    self.report4_location = locations[3]
    self.report5_location = locations[4]
  end
end
