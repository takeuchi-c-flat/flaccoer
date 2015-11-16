require 'rails_helper'

describe WatchUsersController, 'ログイン前' do
  it_behaves_like 'a protected base controller'
end

describe WatchUsersController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for index'
end

describe WatchUsersController, 'ログイン・会計年度選択後' do
  let(:params_hash) { attributes_for(:journal) }
  let(:current_user) { create(:user) }
  let(:current_fiscal_year) { FactoryGirl.create(:fiscal_year, user: current_user) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user, email: 'aaa@local') }
  let(:watch_user1) { create(:watch_user, fiscal_year: current_fiscal_year, user: user1) }
  let(:watch_user2) { create(:watch_user, fiscal_year: current_fiscal_year, user: user2) }

  before do
    # 事前認証とタイムアウトチェックが通るようにしておきます。
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = current_fiscal_year.id
  end

  describe '#index' do
    example 'set @watch_users' do
      get :index
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:watch_users]).to eq([watch_user1, watch_user2])
    end
  end

  describe '#new' do
    example 'set @watch_user' do
      get :new
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:watch_user]).to have_attributes(fiscal_year: current_fiscal_year)
    end
  end

  describe '#edit' do
    example 'set @watch_user' do
      get :edit, id: watch_user2.id
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:watch_user]).to eq(watch_user2)
    end
  end
end
