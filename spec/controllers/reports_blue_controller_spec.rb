require 'rails_helper'

describe ReportsBlueController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe ReportsBlueController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for index'
end

describe ReportsBlueController, 'ログイン・会計年度選択後' do
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
    example 'set @fiscal_year' do
      process :index, method: :get
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
    end
  end
end
