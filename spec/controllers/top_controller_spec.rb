require 'rails_helper'

describe TopController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe TopController, 'ログイン後' do
  let(:params_hash) { attributes_for(:user) }
  let(:current_user) { create(:user) }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
  end

  describe '#index' do
    example '通常はuser/top/indexを表示' do
      get :index
      expect(response).to render_template('top/index')
    end

    example '停止フラグの設定によりログアウト' do
      current_user.update_column(:suspended, true)
      get :index
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_url)
    end

    example 'セッションタイムアウト' do
      session[:last_access_time] = BaseController::TIMEOUT.ago.advance(second: -1)
      get :index
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_url)
    end
  end
end
