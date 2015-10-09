require 'rails_helper'

RSpec.describe BalanceService do
  describe '#pre_create_balances' do
    let(:fiscal_year) { create(:fiscal_year) }
    let(:type_property) { SubjectType.find_by(debit: true, debit_and_credit: true) }
    let(:type_debt) { SubjectType.find_by(credit: true, debit_and_credit: true) }
    let(:subjects) {
      [
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '101A'),
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '102A'),
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '201A'),
        FactoryGirl.create(:subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '202A', disabled: true)
      ]
    }

    example 'no need create' do
      FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[0], top_balance: 10)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[1], top_balance: 20)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[2], top_balance: 30)

      expect(BalanceService.pre_create_balances(fiscal_year)).to eq(0)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[0]).top_balance).to eq(10)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[1]).top_balance).to eq(20)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[2]).top_balance).to eq(30)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[3])).to be_nil
    end

    example 'need create and destroy' do
      FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[1], top_balance: 20)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[3], top_balance: 99)

      expect(BalanceService.pre_create_balances(fiscal_year)).to eq(2)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[0]).top_balance).to eq(0)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[1]).top_balance).to eq(20)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[2]).top_balance).to eq(0)
      expect(Balance.find_by(fiscal_year: fiscal_year, subject: subjects[3])).to be_nil
    end
  end
end
