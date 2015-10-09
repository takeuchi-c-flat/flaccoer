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
    session[:fiscal_year_id] = nil
    session[:journal_date] = nil
  end

  describe '#index' do
    example '通常はtop/indexを表示' do
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

    example 'セッション変数未設定状態＋会計年度なし' do
      get :index
      expect(session[:fiscal_year_id]).to be_nil
      expect(session[:journal_date]).to be_nil
      expect(assigns(:no_years)).to eq(true)
    end

    example 'セッション変数未設定状態＋会計年度あり' do
      FactoryGirl.create(
        :fiscal_year, user: current_user, date_from: Date.new(2016, 1, 1), date_to: Date.new(2016, 12, 31))
      fiscal_year2 = FactoryGirl.create(
        :fiscal_year, user: current_user, date_from: Date.new(2017, 1, 1), date_to: Date.new(2017, 12, 31))
      today = Date.new(2017, 3, 1)
      allow(Date).to receive(:today).and_return(today)

      get :index
      expect(session[:fiscal_year_id]).to eq(fiscal_year2.id)
      expect(session[:journal_date]).to eq(today)
      expect(assigns(:no_years)).to eq(false)
      expect(assigns(:fiscal_year)).to eq(fiscal_year2)
      expect(assigns(:journal_date)).to eq(today)
    end

    example 'セッション変数設定状態' do
      fiscal_year1 = FactoryGirl.create(
        :fiscal_year, user: current_user, date_from: Date.new(2016, 1, 1), date_to: Date.new(2016, 12, 31))
      fiscal_year2 = FactoryGirl.create(
        :fiscal_year, user: current_user, date_from: Date.new(2017, 1, 1), date_to: Date.new(2017, 12, 31))
      today = Date.new(2017, 3, 1)
      session[:fiscal_year_id] = fiscal_year1.id
      session[:journal_date] = today

      get :index
      expect(session[:fiscal_year_id]).to eq(fiscal_year1.id)
      expect(session[:journal_date]).to eq(today)
      expect(assigns(:no_years)).to eq(false)
      expect(assigns(:fiscal_years)).to eq([fiscal_year2, fiscal_year1])
      expect(assigns(:fiscal_year)).to eq(fiscal_year1)
      expect(assigns(:journal_date)).to eq(today)
    end
  end
end
