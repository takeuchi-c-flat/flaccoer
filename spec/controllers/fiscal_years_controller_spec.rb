require 'rails_helper'

describe FiscalYearsController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe FiscalYearsController, 'ログイン後' do
  let(:params_hash) { attributes_for(:fiscal_year) }
  let(:current_user) { create(:user).tap { |u| u.admin_user = true } }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
  end

  # TODO: 実装(respond_to + HTML/JSON 形式のmatcherが分からない)
end
