require 'rails_helper'

RSpec.describe BadgetService do
  describe '#pre_create_badgets' do
    let(:fiscal_year) { create(:fiscal_year) }
    let(:type_profit) { SubjectType.find_by(credit: false, profit_and_loss: true) }
    let(:type_loss) { SubjectType.find_by(credit: true, profit_and_loss: true) }
    let(:subjects) {
      [
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, code: '101A'),
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, code: '102A'),
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, code: '201A'),
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, code: '202A', disabled: true)
      ]
    }

    example 'no need create' do
      FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[0], total_badget: 10)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[1], total_badget: 20)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[2], total_badget: 30)

      expect(BadgetService.pre_create_badgets(fiscal_year)).to eq(0)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[0]).total_badget).to eq(10)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[1]).total_badget).to eq(20)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[2]).total_badget).to eq(30)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[3])).to be_nil
    end

    example 'need create and destroy' do
      FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[1], total_badget: 20)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[3], total_badget: 99)

      expect(BadgetService.pre_create_badgets(fiscal_year)).to eq(2)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[0]).total_badget).to eq(0)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[1]).total_badget).to eq(20)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[2]).total_badget).to eq(0)
      expect(Badget.find_by(fiscal_year: fiscal_year, subject: subjects[3])).to be_nil
    end
  end
end
