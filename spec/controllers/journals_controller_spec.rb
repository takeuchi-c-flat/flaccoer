require 'rails_helper'

describe JournalsController, 'ログイン前' do
  it_behaves_like 'a protected base controller for edit with id'
end

describe JournalsController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for edit with id'
end

describe JournalsController, 'ログイン・会計年度選択後' do
  let(:params_hash) { attributes_for(:journal) }
  let(:current_user) { create(:user) }
  let(:current_fiscal_year) { FactoryGirl.create(:fiscal_year, user: current_user) }
  let(:journal_date) { Date.new(2015, 4, 1) }
  let(:subject1) { create(:subject, fiscal_year: current_fiscal_year, code: '100') }
  let(:subject2) { create(:subject, fiscal_year: current_fiscal_year, code: '200') }
  let(:subject3) { create(:subject, fiscal_year: current_fiscal_year, code: '300') }

  before do
    # 事前認証とタイムアウトチェックが通るようにしておきます。
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = current_fiscal_year.id
    session[:journal_date] = journal_date
  end

  describe '#subjects_debit' do
    example 'set @subjects' do
      allow(JournalsService).to receive(:get_subject_list_with_usage_ranking).
          with(current_fiscal_year, true).
          and_return(['DUMMY'])

      get :subjects_debit
      expect(assigns[:subjects]).to eq(['DUMMY'])
      expect(assigns[:td_class_name]).to eq('select-subject-debit')
    end
  end

  describe '#subjects_credit' do
    example 'set @subjects' do
      allow(JournalsService).to receive(:get_subject_list_with_usage_ranking).
          with(current_fiscal_year, false).
          and_return(['DUMMY'])

      get :subjects_credit
      expect(assigns[:subjects]).to eq(['DUMMY'])
      expect(assigns[:td_class_name]).to eq('select-subject-credit')
    end
  end

  describe '#list' do
    example 'set @journals and more' do
      dummy_journals = [1, 2]
      allow(JournalsService).to \
        receive(:journal_list_from_tab_name).
          with('tab201510', current_fiscal_year).
          and_return(dummy_journals)

      get :list, id: 'tab201510'
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:journals]).to eq(dummy_journals)
    end
  end

  describe '#new' do
    example 'set @journal and more' do
      allow(JournalsService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :new
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:journal]).to have_attributes(fiscal_year: current_fiscal_year)
      expect(assigns[:subjects]).to eq([subject1, subject2, subject3])
    end
  end

  describe '#copy' do
    example 'set @journal and more' do
      create(:journal, id: 9999, fiscal_year: current_fiscal_year, journal_date: Date.new(2015, 1, 31), comment: '1')
      allow(JournalsService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :copy, id: 9999
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:journal]).to have_attributes(
        new_record?: true,
        fiscal_year: current_fiscal_year,
        journal_date: journal_date,
        comment: '1')
      expect(assigns[:subjects]).to eq([subject1, subject2, subject3])
    end
  end

  describe '#edit' do
    example 'set @journal and more' do
      journal = create(
        :journal, id: 9999, fiscal_year: current_fiscal_year, journal_date: Date.new(2015, 1, 31), comment: '1')
      allow(JournalsService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :edit, id: 9999
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:journal]).to eq(journal)
      expect(assigns[:subjects]).to eq([subject1, subject2, subject3])
    end
  end
end
