require 'rails_helper'

describe UsersController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe UsersController, '管理者以外でログイン' do
  let(:current_user) { create(:user) }

  it_behaves_like 'a protected admin base controller'
end

describe UsersController, 'ログイン後' do
  let(:params_hash) { attributes_for(:user) }
  let(:current_user) { create(:user).tap { |u| u.admin_user = true } }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
  end

  # TODO: Test実装
end
