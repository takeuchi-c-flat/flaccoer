require 'rails_helper'

describe BadgetsController, 'ログイン前' do
  it_behaves_like 'a protected base controller for edit with id'
end

describe BadgetsController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for edit with id'
end

describe BadgetsController, 'ログイン・会計年度選択後' do
  let(:params_hash) { attributes_for(:fiscal_year) }
  let(:current_user) { create(:user) }
  let(:current_fiscal_year) { FactoryGirl.create(:fiscal_year, user: current_user) }
  let(:journal_date) { Date.new(2015, 4, 1) }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = current_fiscal_year.id
    session[:journal_date] = journal_date
  end

  describe '#edit' do
    example 'Badgetsを作り込む' do
      expect(BadgetService).to receive(:pre_create_badgets).with(current_fiscal_year).once
      get :edit
    end
  end

  describe '#update' do
    example 'indexにリダイレクト' do
      expect(SubjectService).to receive(:cleanup_subjects).with(current_fiscal_year)

      post :update, fiscal_year: params_hash
      expect(response).to redirect_to(badgets_url)
    end
  end
end
