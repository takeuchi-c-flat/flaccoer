require 'rails_helper'

RSpec.describe LedgerService do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:other_fiscal_year) { create(:fiscal_year) }
  let(:type_property) { SubjectType.find_by(debit: true, debit_and_credit: true) }
  let(:type_debt) { SubjectType.find_by(credit: true, debit_and_credit: true) }
  let(:type_loss) { SubjectType.find_by(debit: true, profit_and_loss: true) }
  let(:type_profit) { SubjectType.find_by(credit: true, profit_and_loss: true) }

  describe '#get_subject_list' do
    example 'get' do
      date = Date.new(2015, 10, 1)
      subject1 = create(:subject, subject_type: type_property, code: '101')
      subject2 = create(:subject, subject_type: type_property, code: '102')
      subject3 = create(:subject, subject_type: type_property, code: '103')
      subject4 = create(:subject, subject_type: type_debt, code: '201')
      create(:subject, subject_type: type_debt, code: '202')
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date,
        subject_debit: subject3, subject_credit: subject4)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date,
        subject_debit: subject2, subject_credit: subject4)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date,
        subject_debit: subject1, subject_credit: subject4)

      expect(LedgerService.get_subject_list(fiscal_year)).to eq([subject1, subject2, subject3, subject4])
    end
  end

  describe '#get_ledger_carried_balance' do
    example 'get' do
      date_from = Date.new(2015, 10, 1)
      subject1 = create(:subject, subject_type: type_property, code: '101')
      subject2 = create(:subject, subject_type: type_property, code: '102')
      subject3 = create(:subject, subject_type: type_debt, code: '201')
      create(:balance, fiscal_year: fiscal_year, subject: subject3, top_balance: 10000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: fiscal_year.date_from,
        subject_debit: subject1, subject_credit: subject3, price: 1000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_from.yesterday,
        subject_debit: subject1, subject_credit: subject3, price: 1000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_from.yesterday,
        subject_debit: subject3, subject_credit: subject2, price: 5000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_from,
        subject_debit: subject3, subject_credit: subject2, price: 9999)

      expect(LedgerService.get_ledger_carried_balance(fiscal_year, subject1, date_from)).to eq(2000)
      expect(LedgerService.get_ledger_carried_balance(fiscal_year, subject2, date_from)).to eq(-5000)
      expect(LedgerService.get_ledger_carried_balance(fiscal_year, subject3, date_from)).to eq(7000)
    end
  end

  describe '#get_ledger_list' do
    example 'get' do
      date_from = Date.new(2015, 10, 1)
      date_to = Date.new(2015, 11, 30)
      subject1 = create(:subject, subject_type: type_property, code: '101')
      subject2 = create(:subject, subject_type: type_property, code: '102')
      subject3 = create(:subject, subject_type: type_debt, code: '201')
      create(:balance, fiscal_year: fiscal_year, subject: subject3, top_balance: 10000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_from,
        subject_debit: subject1, subject_credit: subject3, price: 1000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_from.tomorrow,
        subject_debit: subject1, subject_credit: subject3, price: 1000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_to,
        subject_debit: subject3, subject_credit: subject2, price: 5000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_from.yesterday,
        subject_debit: subject1, subject_credit: subject2, price: 9999)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date_to.tomorrow,
        subject_debit: subject1, subject_credit: subject2, price: 9999)

      actual = LedgerService.get_ledger_list(fiscal_year, subject3, date_from, date_to, 20000)
      expect(actual.length).to eq(3)
      expect(actual[0]).to have_attributes(ledger_subject: subject1, price_debit: 0, price_credit: 1000, balance: 21000)
      expect(actual[1]).to have_attributes(ledger_subject: subject1, price_debit: 0, price_credit: 1000, balance: 22000)
      expect(actual[2]).to have_attributes(ledger_subject: subject2, price_debit: 5000, price_credit: 0, balance: 17000)
    end
  end
end
