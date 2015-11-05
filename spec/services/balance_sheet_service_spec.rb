require 'rails_helper'

RSpec.describe BalanceSheetService do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:type_property) { SubjectType.find_by(debit: true, debit_and_credit: true) }
  let(:type_debt) { SubjectType.find_by(credit: true, debit_and_credit: true) }
  let(:type_loss) { SubjectType.find_by(debit: true, profit_and_loss: true) }
  let(:type_profit) { SubjectType.find_by(credit: true, profit_and_loss: true) }

  describe '#get_balance_sheet_list_debit_and_credit' do
    example 'get' do
      date = Date.new(2015, 10, 1)
      subject1 = create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '101', name: '現金')
      subject2 = create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '102', name: '普通預金')
      create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '103', name: '有価証券')
      create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '104', name: '固定資産')
      subject3 = create(:subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '201', name: '未払金')
      create(:subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '203', name: '科目202', disabled: true)
      subject4 = create(:subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '299', name: '元入金')
      profit = create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, code: '301', name: '売上')

      create(:balance, subject: subject2, top_balance: 1000000)
      create(:balance, subject: subject3, top_balance: 20000)
      create(:balance, subject: subject4, top_balance: 1020000)

      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date.yesterday,
        subject_debit: subject3, subject_credit: subject2, price: 10000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date,
        subject_debit: subject1, subject_credit: subject2, price: 20000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: fiscal_year.date_to,
        subject_debit: subject2, subject_credit: profit, price: 600000)

      actual = BalanceSheetService.get_balance_sheet_list_debit_and_credit(fiscal_year, date, fiscal_year.date_to)
      expect(actual.length).to eq(4)
      expect(actual[0][0]).to have_attributes(name: '現金', carried: 0, total: 20000, last_balance: 20000)
      expect(actual[0][1]).to have_attributes(name: '未払金', carried: 10000, total: 0, last_balance: 10000)
      expect(actual[1][0]).to have_attributes(name: '普通預金', carried: 990000, total: 580000, last_balance: 1570000)
      expect(actual[1][1]).to have_attributes(name: '元入金', carried: 1020000, total: 0, last_balance: 1020000)
      expect(actual[2][0]).to have_attributes(name: '有価証券', carried: 0, total: 0, last_balance: 0)
      expect(actual[2][1]).to have_attributes(name: nil, carried: nil, total: nil, last_balance: nil)
      expect(actual[3][0]).to have_attributes(name: '固定資産', carried: 0, total: 0, last_balance: 0)
      expect(actual[3][1]).to have_attributes(name: '＊＊剰余金＊＊', carried: 0, total: 600000, last_balance: 600000)
    end
  end

  describe '#get_balance_sheet_list_profit_and_loss' do
    example 'get' do
      date = Date.new(2015, 10, 1)
      subject1 = create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, code: '401', name: '消耗品')
      subject2 = create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, code: '402', name: '通信費')
      subject3 = create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, code: '301', name: '売上')
      create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, code: '104', name: '雑収入', disabled: true)
      deposit = create(:subject, fiscal_year: fiscal_year, subject_type: type_property, code: '102', name: '普通預金')

      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date.yesterday,
        subject_debit: deposit, subject_credit: subject3, price: 60000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: date,
        subject_debit: subject1, subject_credit: deposit, price: 20000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: fiscal_year.date_to,
        subject_debit: subject2, subject_credit: deposit, price: 12000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: fiscal_year.date_to,
        subject_debit: deposit, subject_credit: subject3, price: 600000)

      actual = BalanceSheetService.get_balance_sheet_list_profit_and_loss(fiscal_year, date, fiscal_year.date_to)
      expect(actual.length).to eq(3)
      expect(actual[0][0]).to have_attributes(name: '消耗品', carried: 0, total: 20000, last_balance: 20000)
      expect(actual[0][1]).to have_attributes(name: '売上', carried: 60000, total: 600000, last_balance: 660000)
      expect(actual[1][0]).to have_attributes(name: '通信費', carried: 0, total: 12000, last_balance: 12000)
      expect(actual[1][1]).to have_attributes(name: nil, carried: nil, total: nil, last_balance: nil)
      expect(actual[2][0]).to have_attributes(name: '＊＊剰余金＊＊', carried: 60000, total: 568000, last_balance: 628000)
      expect(actual[2][1]).to have_attributes(name: nil, carried: nil, total: nil, last_balance: nil)
    end
  end
end
