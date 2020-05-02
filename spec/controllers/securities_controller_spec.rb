require 'rails_helper'

describe SecuritiesController, 'ログイン前' do
  it_behaves_like 'a protected base controller for edit with id'
end

describe SecuritiesController, 'ログイン後' do
  let(:params_hash) { attributes_for(:user) }
  let(:current_user) { create(:user) }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
  end

  describe '#edit' do
    example '通常はsecurityを表示' do
      process :edit, method: :get
      expect(response).to render_template('edit')
    end

    example '停止フラグの設定によりログアウト' do
      current_user.update_column(:suspended, true)
      process :edit, method: :get
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_url)
    end

    example 'セッションタイムアウト' do
      session[:last_access_time] = BaseController::TIMEOUT.ago.advance(second: -1)
      process :edit, method: :get
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_url)
    end
  end

  describe '#update' do
    let(:user) { create(:user) }

    example '現在のパスワードが不一致' do
      params_hash[:password] = 'dummy'

      process :update, method: :patch, params: { id: user.id, user: params_hash }
      expect(response).to render_template('edit')
    end

    example '新しいパスワードが不一致' do
      params_hash[:password] = 'password'
      params_hash[:new_password1] = 'a'
      params_hash[:new_password2] = 'b'
      process :update, method: :patch, params: { id: user.id, user: params_hash }
      expect(response).to render_template('edit')
    end

    example 'パスワードが一致してログイン画面にredirect' do
      params_hash[:password] = 'password'
      params_hash[:new_password1] = 'a'
      params_hash[:new_password2] = 'a'
      process :update, method: :patch, params: { id: user.id, user: params_hash }
      expect(response).to redirect_to(login_url)
    end
  end
end
