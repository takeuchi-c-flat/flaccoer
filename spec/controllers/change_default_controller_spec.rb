require 'rails_helper'

describe ChangeDefaultController, 'ログイン前' do
  it_behaves_like 'a protected base controller for edit with id'
end

describe ChangeDefaultController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for edit with id'
end

describe ChangeDefaultController, 'ログイン・会計年度選択後' do
  let(:params_hash) { attributes_for(:user) }
  let(:fiscal_year) { create(:fiscal_year) }
  let(:current_user) { fiscal_year.user }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = fiscal_year.id
    session[:journal_date] = nil
  end

  describe '#edit' do
    example 'get' do
      dummy_years = [fiscal_year, nil]
      allow(FiscalYearService).to receive(:accessible_fiscal_years).with(fiscal_year.user).and_return(dummy_years)
      today = Date.new(2015, 4, 1)
      allow(Date).to receive(:today).and_return(today)

      get :edit
      expect(assigns[:fiscal_years]).to eq(dummy_years)
      expect(assigns[:change_default_form].fiscal_year_id).to eq(fiscal_year.id)
      expect(assigns[:change_default_form].journal_date).to eq(today)
    end
  end

  describe '#change' do
    example 'post' do
      fiscal_year1 = FactoryGirl.create(
        :fiscal_year, user: current_user, date_from: Date.new(2016, 1, 1), date_to: Date.new(2016, 12, 31))
      FactoryGirl.create(
        :fiscal_year, user: current_user, date_from: Date.new(2017, 1, 1), date_to: Date.new(2017, 12, 31))
      today = Date.new(2017, 3, 1)

      params_hash = { fiscal_year_id: fiscal_year1.id, journal_date: today }
      post :change, change_default_form: params_hash
      expect(session[:fiscal_year_id]).to eq(fiscal_year1.id.to_s)
      expect(session[:journal_date]).to eq('2016-12-31')
      expect(response).to redirect_to(root_url)
    end
  end
end
