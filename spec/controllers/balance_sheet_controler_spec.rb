require 'rails_helper'

describe BalanceSheetController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe BalanceSheetController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for index'
end

describe BalanceSheetController, 'ログイン・会計年度選択後' do
  let(:current_user) { create(:user) }
  let(:current_fiscal_year) { FactoryGirl.create(:fiscal_year, user: current_user) }
  let(:subject) { create(:subject, fiscal_year: current_fiscal_year) }

  before do
    # 事前認証とタイムアウトチェックが通るようにしておきます。
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = current_fiscal_year.id
  end

  describe '#index' do
    example 'set @balance_sheet_form and more' do
      process :index, method: :get
      expect(assigns[:balance_sheet_form]).to have_attributes(
        date_from: current_fiscal_year.date_from,
        date_to: current_fiscal_year.date_to)
    end
  end

  describe '#list' do
    example 'set @balance_sheet_list and more' do
      date_from = Date.new(2015, 5, 1)
      date_to = Date.new(2015, 7, 31)
      allow(BalanceSheetService).to receive(:get_balance_sheet_list_debit_and_credit).
          with(current_fiscal_year, date_from, date_to).
          and_return(['DUMMY1'])
      allow(BalanceSheetService).to receive(:get_balance_sheet_list_profit_and_loss).
          with(current_fiscal_year, date_from, date_to).
          and_return(['DUMMY2'])

      process :list, method: :post, params: { balance_sheet_form: { date_from: '2015/05/01', date_to: '2015/07/31' } }
      expect(assigns[:balance_sheet_list]).to eq([
        { title: '貸借対照表', list: ['DUMMY1']},
        { title: '損益計算書', list: ['DUMMY2']}
      ])
    end
  end
end
