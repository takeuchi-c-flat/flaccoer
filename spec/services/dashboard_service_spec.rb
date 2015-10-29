require 'rails_helper'

RSpec.describe DashboardService do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:other_fiscal_year) { create(:fiscal_year) }
  let(:type_property) { SubjectType.find_by(debit: true, debit_and_credit: true) }
  let(:type_debt) { SubjectType.find_by(credit: true, debit_and_credit: true) }
  let(:type_loss) { SubjectType.find_by(debit: true, profit_and_loss: true) }
  let(:type_profit) { SubjectType.find_by(credit: true, profit_and_loss: true) }
  let(:date_from) { fiscal_year.date_from }
  let(:journal_date) { fiscal_year.date_to.beginning_of_month }

  def create_subject(type, code, name, dash_board = true, disabled = false)
    create(
      :subject,
      fiscal_year: fiscal_year, subject_type: type,
      code: code, name: name, dash_board: dash_board, disabled: disabled)
  end

  def create_other_subject(type, code, name)
    create(
      :subject,
      fiscal_year: other_fiscal_year, subject_type: type,
      code: code, name: name, dash_board: true, disabled: false)
  end

  def create_journal(date, debit, credit, price)
    create(
      :journal,
      fiscal_year: fiscal_year, journal_date: date,
      subject_debit: debit, subject_credit: credit, price: price)
  end

  example '#create_dashboard_data_debit_and_credit' do
    property1 = create_subject(type_property, '101', '現金').tap { |s|
      s.balance = create(:balance, top_balance: 50000)
    }
    property2 = create_subject(type_property, '102', '普通預金').tap { |s|
      s.balance = create(:balance, top_balance: 500000)
    }
    create_subject(type_property, '191', '対象外資産', false)
    create_subject(type_property, '192', '無効資産', true, true)
    create_other_subject(type_property, '101', '別会計資産')
    debt1 = create_subject(type_debt, '201', '未払金')
    loss1 = create_subject(type_loss, '401', '消耗品費')

    create_journal(date_from, property1, property2, 100000)
    create_journal(date_from, loss1, debt1, 10000)
    create_journal(journal_date, debt1, property1, 5000)
    create_journal(journal_date.tomorrow, property1, property2, 999999999)

    actual = DashboardService.create_dashboard_data_debit_and_credit(fiscal_year, journal_date)
    expect(actual.length).to eq(3)
    expect(actual[0]).to have_attributes(
      code: '101', name: '現金',
      top_balance: 50000, debit_total: 100000, credit_total: 5000, last_balance: 145000)
    expect(actual[1]).to have_attributes(
      code: '102', name: '普通預金',
      top_balance: 500000, debit_total: 0, credit_total: 100000, last_balance: 400000)
    expect(actual[2]).to have_attributes(
      code: '201', name: '未払金',
      top_balance: 0, debit_total: 5000, credit_total: 10000, last_balance: 5000)
  end

  example '#create_dashboard_data_profit_and_loss' do
    property1 = create_subject(type_property, '101', '現金')
    profit1 = create_subject(type_profit, '301', '売上').tap { |s|
      s.badget = create(:badget, total_badget: 1000000)
    }
    create_subject(type_profit, '391', '対象外収入', false)
    create_subject(type_property, '392', '無効収入', true, true)
    create_other_subject(type_property, '101', '別会計資産')
    loss1 = create_subject(type_loss, '401', '消耗品費')
    loss2 = create_subject(type_loss, '402', '通信費')

    create_journal(date_from, property1, profit1, 150000)
    create_journal(date_from, loss1, property1, 20000)
    create_journal(journal_date, loss2, property1, 50000)
    create_journal(journal_date, property1, loss2, 5000)
    create_journal(journal_date.tomorrow, property1, profit1, 999999999)

    actual = DashboardService.create_dashboard_data_profit_and_loss(fiscal_year, journal_date)
    expect(actual.length).to eq(3)
    expect(actual[0]).to have_attributes(
      code: '301', name: '売上',
      total_badget: 1000000, total_result: 150000, achievement_ratio: '15.0%')
    expect(actual[1]).to have_attributes(
      code: '401', name: '消耗品費',
      total_badget: 0, total_result: 20000, achievement_ratio: '---%')
    expect(actual[2]).to have_attributes(
      code: '402', name: '通信費',
      total_badget: 0, total_result: 45000, achievement_ratio: '---%')
  end
end
