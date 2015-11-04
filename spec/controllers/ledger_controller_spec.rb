require 'rails_helper'

describe LedgerController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe LedgerController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for index'
end

describe LedgerController, 'ログイン・会計年度選択後' do
  let(:current_user) { create(:user) }
  let(:current_fiscal_year) { FactoryGirl.create(:fiscal_year, user: current_user) }
  let(:journal_date) { Date.new(2015, 4, 1) }
  let(:subject) { create(:subject, fiscal_year: current_fiscal_year) }

  before do
    # 事前認証とタイムアウトチェックが通るようにしておきます。
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = current_fiscal_year.id
    session[:journal_date] = journal_date
  end

  describe '#index' do
    example 'set @ledger_form and more' do
      allow(LedgerService).to receive(:get_subject_list).with(current_fiscal_year).and_return(['DUMMY'])

      get :index
      expect(assigns[:ledger_form]).to have_attributes(
        date_from: current_fiscal_year.date_from,
        date_to: current_fiscal_year.date_to)
      expect(assigns[:subjects]).to eq(['DUMMY'])
    end
  end

  describe '#list' do
    example 'set @ledger_list and more' do
      allow(LedgerService).to receive(:get_ledger_carried_balance).
          with(current_fiscal_year, subject, Date.new(2015, 5, 1).to_s).
          and_return(50000)
      allow(LedgerService).to receive(:get_ledger_list).
          with(current_fiscal_year, subject, Date.new(2015, 5, 1).to_s, Date.new(2015, 7, 1).to_s, 50000).
          and_return(['DUMMY'])

      get :list, ledger_form: { subject_id: subject.id, date_from: Date.new(2015, 5, 1), date_to: Date.new(2015, 7, 1) }
      expect(assigns[:carried_balance]).to eq(50000)
      expect(assigns[:ledger_list]).to eq(['DUMMY'])
    end
  end
end
