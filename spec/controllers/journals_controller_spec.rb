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
      allow(SubjectsCacheService).to receive(:get_subject_list_with_usage_ranking).
          with(current_fiscal_year, true).
          and_return(['DUMMY'])

      get :subjects_debit
      expect(assigns[:subjects]).to eq(['DUMMY'])
      expect(assigns[:td_class_name]).to eq('select-subject-debit')
    end
  end

  describe '#subjects_credit' do
    example 'set @subjects' do
      expect(SubjectsCacheService).to receive(:get_subject_list_with_usage_ranking).
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
      expect(JournalsService).to \
        receive(:journal_list_from_tab_name).
          with('tab201510', current_fiscal_year).
          and_return(dummy_journals)

      get :list, id: 'tab201510'
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:can_modify]).to eq(true)
      expect(assigns[:journals]).to eq(dummy_journals)
    end
  end

  describe '#new' do
    example 'set @journal and more' do
      expect(SubjectsCacheService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :new
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:can_modify]).to eq(true)
      expect(assigns[:journal]).to have_attributes(fiscal_year: current_fiscal_year)
      expect(assigns[:subjects]).to eq([subject1, subject2, subject3])
    end
  end

  describe '#copy' do
    example 'set @journal and more' do
      create(:journal, id: 9999, fiscal_year: current_fiscal_year, journal_date: Date.new(2015, 1, 31), comment: '1')
      expect(SubjectsCacheService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :copy, id: 9999
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:can_modify]).to eq(true)
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
      expect(SubjectsCacheService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :edit, id: 9999
      expect(assigns[:fiscal_year]).to eq(current_fiscal_year)
      expect(assigns[:journal_date]).to eq(journal_date)
      expect(assigns[:can_modify]).to eq(true)
      expect(assigns[:journal]).to eq(journal)
      expect(assigns[:subjects]).to eq([subject1, subject2, subject3])
    end
  end
end

describe JournalsController, '編集権限のない閲覧ユーザでログイン・会計年度選択後' do
  let(:params_hash) { attributes_for(:journal) }
  let(:main_user) { create(:user) }
  let(:current_user) { create(:user) }
  let(:current_fiscal_year) { FactoryGirl.create(:fiscal_year, user: main_user) }
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
    create(:watch_user, fiscal_year: current_fiscal_year, user: current_user, can_modify: false)
  end

  describe '#new' do
    example 'set @journal and more' do
      expect(SubjectsCacheService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :new
      expect(assigns[:can_modify]).to eq(false)
    end
  end

  describe '#copy' do
    example 'set @journal and more' do
      create(:journal, id: 9999, fiscal_year: current_fiscal_year, journal_date: Date.new(2015, 1, 31), comment: '1')
      expect(SubjectsCacheService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :copy, id: 9999
      expect(assigns[:can_modify]).to eq(false)
    end
  end

  describe '#edit' do
    example 'set @journal and more' do
      create(:journal, id: 9999, fiscal_year: current_fiscal_year, journal_date: Date.new(2015, 1, 31), comment: '1')
      expect(SubjectsCacheService).to \
        receive(:get_subject_list).with(current_fiscal_year).and_return([subject1, subject2, subject3])

      get :edit, id: 9999
      expect(assigns[:can_modify]).to eq(false)
    end
  end

  describe '#set_mark' do
    example 'set_mark success' do
      create(:journal, id: 99999999, fiscal_year: current_fiscal_year, mark: false)

      patch :set_mark, id: 99999999
      expect(Journal.find(99999999).mark).to eq(true)
    end

    example 'fiscal_year not match' do
      dummy_fiscal_year = create(:fiscal_year)
      create(:journal, id: 99999999, fiscal_year: dummy_fiscal_year, mark: false)

      patch :set_mark, id: 99999999
      expect(Journal.find(99999999).mark).to eq(false)
    end
  end

  describe '#reset_mark' do
    example 'reset_mark success' do
      create(:journal, id: 99999999, fiscal_year: current_fiscal_year, mark: true)

      patch :reset_mark, id: 99999999
      expect(Journal.find(99999999).mark).to eq(false)
    end

    example 'not found journal' do
      patch :reset_mark, id: 99999999
      expect(Journal.find_by(id: 99999999)).to be_nil
    end
  end
end

