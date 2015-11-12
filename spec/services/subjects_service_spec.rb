require 'rails_helper'

RSpec.describe SubjectsService do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:dummy_subject1) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: 'D1') }
  let(:dummy_subject2) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: 'D2') }
  let(:disabled_subject) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: 'D3', disabled: true) }

  describe '#subject_can_delete?' do
    let(:subject_with_journal1) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '1') }
    let(:subject_with_journal2) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '2') }

    example 'can not delete(with debit subject)' do
      FactoryGirl.create(
        :journal, fiscal_year: fiscal_year, subject_debit: subject_with_journal1, subject_credit: dummy_subject1)

      expect(SubjectsService.subject_can_delete?(fiscal_year, subject_with_journal1)).to eq(false)
    end

    example 'can not delete(with credit subject)' do
      FactoryGirl.create(
        :journal, fiscal_year: fiscal_year, subject_debit: dummy_subject1, subject_credit: subject_with_journal2)

      expect(SubjectsService.subject_can_delete?(fiscal_year, subject_with_journal2)).to eq(false)
    end

    example 'can delete' do
      FactoryGirl.create(
        :journal, fiscal_year: fiscal_year, subject_debit: dummy_subject1, subject_credit: dummy_subject2)

      expect(SubjectsService.subject_can_delete?(fiscal_year, subject_with_journal1)).to eq(true)
      expect(SubjectsService.subject_can_delete?(fiscal_year, subject_with_journal2)).to eq(true)
    end
  end

  describe '#cleanup_subjects?' do
    example 'cleanup' do
      create(:balance, fiscal_year: fiscal_year, subject: dummy_subject1, top_balance: 10)
      create(:balance, fiscal_year: fiscal_year, subject: dummy_subject2, top_balance: 0)
      create(:balance, fiscal_year: fiscal_year, subject: disabled_subject, top_balance: 10)
      create(:badget, fiscal_year: fiscal_year, subject: dummy_subject1, total_badget: 0)
      create(:badget, fiscal_year: fiscal_year, subject: dummy_subject2, total_badget: 20)
      create(:badget, fiscal_year: fiscal_year, subject: disabled_subject, total_badget: 20)

      SubjectsService.cleanup_subjects(fiscal_year)
      balances = Balance.where(fiscal_year: fiscal_year)
      expect(balances.length).to eq(1)
      expect(balances[0].subject.code).to eq('D1')
      badgets = Badget.where(fiscal_year: fiscal_year)
      expect(badgets.length).to eq(1)
      expect(badgets[0].subject.code).to eq('D2')
    end
  end

  describe '#get_subject_list' do
    before do
      create(:subject, fiscal_year: fiscal_year, code: '201')
      create(:subject, fiscal_year: fiscal_year, code: '202')
      create(:subject, fiscal_year: fiscal_year, code: '101')
      create(:subject, fiscal_year: fiscal_year, code: '102')
    end

    it 'with sort' do
      actual = SubjectsService.get_subject_list(fiscal_year)
      expect(actual.map(&:code)).to eq(%w(101 102 201 202))
    end

    it 'without sort' do
      actual = SubjectsService.get_subject_list(fiscal_year, false)
      expect(actual.map(&:code)).to eq(%w(201 202 101 102))
    end
  end

  describe '#create_subject_list_with_usage_ranking' do
    let(:fiscal_year) { create(:fiscal_year) }

    before do
      subject1 = create(:subject, fiscal_year: fiscal_year, code: '101')
      subject2 = create(:subject, fiscal_year: fiscal_year, code: '102')
      subject3 = create(:subject, fiscal_year: fiscal_year, code: '201')
      subject4 = create(:subject, fiscal_year: fiscal_year, code: '202')
      create(:journal, fiscal_year: fiscal_year, subject_debit: subject3, subject_credit: subject2)
      create(:journal, fiscal_year: fiscal_year, subject_debit: subject3, subject_credit: subject2)
      create(:journal, fiscal_year: fiscal_year, subject_debit: subject3, subject_credit: subject1)
      create(:journal, fiscal_year: fiscal_year, subject_debit: subject4, subject_credit: subject3)
      Rails.cache.clear
    end

    after do
      Rails.cache.clear
    end

    it 'get subjects for debit' do
      actual = SubjectsService.create_subject_list_with_usage_ranking(fiscal_year, true)
      expect(actual.map(&:code)).to eq(%w(201 202 101 102))
    end

    it 'get subjects for credit' do
      actual = SubjectsService.create_subject_list_with_usage_ranking(fiscal_year, false)
      expect(actual.map(&:code)).to eq(%w(102 101 201 202))
    end
  end
end
