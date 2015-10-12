require 'rails_helper'

RSpec.describe SubjectService do
  describe '#subject_can_delete?' do
    let(:fiscal_year) { create(:fiscal_year) }
    let(:subject_with_journal1) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '1') }
    let(:subject_with_journal2) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '2') }
    let(:dummy_subject1) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: 'D1') }
    let(:dummy_subject2) { FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: 'D2') }

    example 'can not delete(with debit subject)' do
      FactoryGirl.create(
        :journal, fiscal_year: fiscal_year, subject_debit: subject_with_journal1, subject_credit: dummy_subject1)

      expect(SubjectService.subject_can_delete?(fiscal_year, subject_with_journal1)).to eq(false)
    end

    example 'can not delete(with credit subject)' do
      FactoryGirl.create(
        :journal, fiscal_year: fiscal_year, subject_debit: dummy_subject1, subject_credit: subject_with_journal2)

      expect(SubjectService.subject_can_delete?(fiscal_year, subject_with_journal2)).to eq(false)
    end

    example 'can delete' do
      FactoryGirl.create(
        :journal, fiscal_year: fiscal_year, subject_debit: dummy_subject1, subject_credit: dummy_subject2)

      expect(SubjectService.subject_can_delete?(fiscal_year, subject_with_journal1)).to eq(true)
      expect(SubjectService.subject_can_delete?(fiscal_year, subject_with_journal2)).to eq(true)
    end
  end
end
