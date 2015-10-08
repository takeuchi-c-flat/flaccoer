require 'rails_helper'

describe FiscalYearsMaintenanceController, 'ログイン前' do
  it_behaves_like 'a protected base controller for index with id'
end

describe FiscalYearsMaintenanceController, 'ログイン後' do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:current_user) { create(:user).tap { |u| u.admin_user = true } }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
  end

  describe '#index' do
    example '各種件数を取得' do
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year)

      get :index, id: fiscal_year.id
      expect(assigns[:fiscal_year]).to eq(fiscal_year)
      expect(assigns[:journals_count]).to eq(3)
      expect(assigns[:balances_count]).to eq(2)
      expect(assigns[:badgets_count]).to eq(1)
    end

    example '会計年度未指定時は、会計年度一覧へリダイレクト' do
      get :index, id: 0
      expect(response).to redirect_to(fiscal_years_url)
    end
  end
end
