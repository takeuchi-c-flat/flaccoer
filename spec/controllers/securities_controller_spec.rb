require 'rails_helper'

describe SecuritiesController, 'ログイン前' do
  example 'ログインフォームにリダイレクト' do
    get :edit
    expect(response).to redirect_to(login_url)
  end
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
      get :edit
      expect(response).to render_template('edit')
    end

    example '停止フラグの設定によりログアウト' do
      current_user.update_column(:suspended, true)
      get :edit
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_url)
    end

    example 'セッションタイムアウト' do
      session[:last_access_time] = BaseController::TIMEOUT.ago.advance(second: -1)
      get :edit
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_url)
    end
  end

  describe '#update' do
    let(:user) { create(:user) }

    example '現在のパスワードが不一致' do
      params_hash[:password] = 'dummy'
      patch :update, id: user.id, user: params_hash
      expect(response).to render_template('edit')
    end

    example '新しいパスワードが不一致' do
      params_hash[:password] = 'password'
      params_hash[:new_password1] = 'a'
      params_hash[:new_password2] = 'b'
      patch :update, id: user.id, user: params_hash
      expect(response).to render_template('edit')
    end

    example 'パスワードが一致してログイン画面にredirect' do
      params_hash[:password] = 'password'
      params_hash[:new_password1] = 'a'
      params_hash[:new_password2] = 'a'
      patch :update, id: user.id, user: params_hash
      expect(response).to redirect_to(login_url)
    end
  end
end
