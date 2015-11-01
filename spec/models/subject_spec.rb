require 'rails_helper'

RSpec.describe Subject do
  let(:type_property) { SubjectType.find_by(debit_and_credit: true, debit: true) }
  let(:type_debt) { SubjectType.find_by(debit_and_credit: true, credit: true) }
  let(:type_profit) { SubjectType.find_by(profit_and_loss: true, credit: true) }
  let(:type_loss) { SubjectType.find_by(profit_and_loss: true, debit: true) }

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

  describe '#mark_class_name' do
    example 'get' do
      expect(Subject.new.mark_class_name).to eq('')
      expect(Subject.new.tap { |m| m.subject_type = type_property }.mark_class_name).to eq('mark-property')
      expect(Subject.new.tap { |m| m.subject_type = type_debt }.mark_class_name).to eq('mark-debt')
      expect(Subject.new.tap { |m| m.subject_type = type_profit }.mark_class_name).to eq('mark-profit')
      expect(Subject.new.tap { |m| m.subject_type = type_loss }.mark_class_name).to eq('mark-loss')
    end
  end

  describe '#mark_label_name' do
    example 'get' do
      expect(Subject.new.mark_label_name).to eq('')
      expect(Subject.new.tap { |m| m.subject_type = type_property }.mark_label_name).to eq('資')
      expect(Subject.new.tap { |m| m.subject_type = type_debt }.mark_label_name).to eq('負')
      expect(Subject.new.tap { |m| m.subject_type = type_profit }.mark_label_name).to eq('収')
      expect(Subject.new.tap { |m| m.subject_type = type_loss }.mark_label_name).to eq('支')
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
