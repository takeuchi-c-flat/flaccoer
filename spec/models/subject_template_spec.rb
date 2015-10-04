require 'rails_helper'

RSpec.describe SubjectTemplate do
  describe '#get_report_locations' do
    example 'get' do
      template = create(:subject_template).tap { |m|
        m.report1_location = 101
        m.report2_location = 102
        m.report3_location = nil
        m.report4_location = 104
        m.report5_location = 105
      }
      expect(template.get_report_locations).to eq([101, 102, nil, 104, 105])
    end
  end
end
