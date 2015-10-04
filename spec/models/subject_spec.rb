require 'rails_helper'

RSpec.describe Subject do
  describe '#get_report_locations' do
    example 'get' do
      subject = create(:subject).tap { |m|
        m.report1_location = 101
        m.report2_location = 102
        m.report3_location = nil
        m.report4_location = 104
        m.report5_location = 105
      }
      expect(subject.get_report_locations).to eq([101, 102, nil, 104, 105])
    end
  end

  describe '#to_s' do
    example 'get' do
      subject = create(:subject).tap { |m| m.name = '科目名称' }
      expect(subject.to_s).to eq('科目名称')
    end
  end

  describe '#set_report_locations' do
    example 'set' do
      subject = create(:subject)
      subject.set_report_locations([101, 102, nil, 104, 105])
      expect(subject.get_report_locations).to eq([101, 102, nil, 104, 105])
    end
  end
end
