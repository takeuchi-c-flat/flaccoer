require 'rails_helper'

describe FiscalYearsMaintenanceController, 'ログイン前' do
  it_behaves_like 'a protected base controller for index with id'
end

describe FiscalYearsMaintenanceController, 'ログイン後' do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:current_user) { create(:user).tap { |u| u.admin_user = true } }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
  end

  describe '#index' do
    example 'set attributes with balances and badgets' do
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '100')
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '200')
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '300')
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year)

      get :index, id: fiscal_year.id
      expect(assigns[:maintenance_items]).to eq(
        [
          {
            title: '取引明細',
            count: 2,
            any_records: true,
            can_delete: true,
            delete_path: trunc_journals_path(fiscal_year),
            export_path: export_journals_path(fiscal_year)
          },
          {
            title: '勘定科目',
            count: 3,
            any_records: true,
            can_delete: false,
            delete_path: trunc_subjects_path(fiscal_year),
            export_path: export_subjects_path(fiscal_year)
          },
          {
            title: '期首残高',
            count: 2,
            any_records: true,
            can_delete: true,
            delete_path: trunc_balances_path(fiscal_year),
            export_path: export_balances_path(fiscal_year)
          },
          {
            title: '年間予算',
            count: 1,
            any_records: true,
            can_delete: true,
            delete_path: trunc_badgets_path(fiscal_year),
            export_path: export_badgets_path(fiscal_year)
          }
        ])
    end

    example 'set attributes without journals' do
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '100')
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '200')

      get :index, id: fiscal_year.id
      expect(assigns[:maintenance_items]).to eq(
        [
          {
            title: '取引明細',
            count: 0,
            any_records: false,
            can_delete: false,
            delete_path: trunc_journals_path(fiscal_year),
            export_path: export_journals_path(fiscal_year)
          },
          {
            title: '勘定科目',
            count: 2,
            any_records: true,
            can_delete: true,
            delete_path: trunc_subjects_path(fiscal_year),
            export_path: export_subjects_path(fiscal_year)
          },
          {
            title: '期首残高',
            count: 0,
            any_records: false,
            can_delete: false,
            delete_path: trunc_balances_path(fiscal_year),
            export_path: export_balances_path(fiscal_year)
          },
          {
            title: '年間予算',
            count: 0,
            any_records: false,
            can_delete: false,
            delete_path: trunc_badgets_path(fiscal_year),
            export_path: export_badgets_path(fiscal_year)
          }
        ])
    end

    example 'redirect to fiscal_years when not assign fiscal_year' do
      get :index, id: 0
      expect(response).to redirect_to(fiscal_years_url)
    end
  end

  describe '#trunc_journals' do
    example 'truncate' do
      other_fiscal_year = create(:fiscal_year)
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      FactoryGirl.create(:journal, fiscal_year: other_fiscal_year)

      delete :trunc_journals, id: fiscal_year.id
      expect(Journal.where(fiscal_year: fiscal_year).empty?).to eq(true)
      expect(Journal.where(fiscal_year: other_fiscal_year).length).to eq(1)
      expect(response).to redirect_to(fiscal_year_maintenance_path)
    end
  end

  describe '#trunc_subjects' do
    example 'truncate' do
      other_fiscal_year = create(:fiscal_year)
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '100')
      FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '200')
      FactoryGirl.create(:subject, fiscal_year: other_fiscal_year, code: '100')

      delete :trunc_subjects, id: fiscal_year.id
      expect(Subject.where(fiscal_year: fiscal_year).empty?).to eq(true)
      expect(Subject.where(fiscal_year: other_fiscal_year).length).to eq(1)
      expect(response).to redirect_to(fiscal_year_maintenance_path)
    end
  end

  describe '#trunc_balances' do
    example 'truncate' do
      other_fiscal_year = create(:fiscal_year)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      FactoryGirl.create(:balance, fiscal_year: other_fiscal_year)

      delete :trunc_balances, id: fiscal_year.id
      expect(Balance.where(fiscal_year: fiscal_year).empty?).to eq(true)
      expect(Balance.where(fiscal_year: other_fiscal_year).length).to eq(1)
      expect(response).to redirect_to(fiscal_year_maintenance_path)
    end
  end

  describe '#trunc_badgets' do
    example 'truncate' do
      other_fiscal_year = create(:fiscal_year)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year)
      FactoryGirl.create(:badget, fiscal_year: fiscal_year)
      FactoryGirl.create(:badget, fiscal_year: other_fiscal_year)

      delete :trunc_badgets, id: fiscal_year.id
      expect(Badget.where(fiscal_year: fiscal_year).empty?).to eq(true)
      expect(Badget.where(fiscal_year: other_fiscal_year).length).to eq(1)
      expect(response).to redirect_to(fiscal_year_maintenance_path)
    end
  end
end
