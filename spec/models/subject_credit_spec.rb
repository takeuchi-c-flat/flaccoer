require 'rails_helper'

RSpec.describe SubjectCredit do
  describe '#to_s' do
    example 'get' do
      subject = create(:subject_credit).tap { |m| m.name = '科目名称' }
      expect(subject.to_s).to eq('科目名称')
    end
  end
end
