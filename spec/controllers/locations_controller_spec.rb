require 'rails_helper'

describe LocationsController, 'ログイン前' do
  it_behaves_like 'a protected base controller for edit_all'
end

describe LocationsController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for edit_all'
end

describe LocationsController, 'ログイン・会計年度選択後' do
  let(:current_user) { create(:user) }
  let(:account_type) { AccountType.find(1) }
  let(:subject_template_type) { FactoryGirl.create(:subject_template_type, account_type: account_type) }
  let(:fiscal_year) {
    FactoryGirl.create(:fiscal_year, subject_template_type: subject_template_type, user: current_user)
  }
  let(:journal_date) { Date.new(2015, 4, 1) }
  let(:subject_types) { SubjectType.where(account_type_id: 1) }

  let(:params_hash) { attributes_for(:fiscal_year) }
  let(:subject_params_hash) {
    attributes_for(:subject).tap { |h|
      h[:subject_template_type] = subject_template_type
      h[:subject_type_id] = subject_types.first.id
    }
  }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = fiscal_year.id
    session[:journal_date] = journal_date
  end

  describe '#edit_all' do
    example 'assign fiscal_year' do
      process :edit_all, method: :get
      expect(assigns(:fiscal_year)).to eq(fiscal_year)
    end
  end

  describe '#update_all' do
    example 'indexにリダイレクト' do
      process :update_all, method: :post, params: { fiscal_year: params_hash }
      expect(response).to redirect_to(locations_url)
    end
  end
end
