require 'rails_helper'

RSpec.describe JournalsService do
  describe '#create_journal_months' do
    let(:fiscal_year) { create(:fiscal_year, date_from: Date.new(2015, 9, 1), date_to: Date.new(2016, 1, 15)) }

    example 'create' do
      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 10, 15))
      expect(actual.length).to eq(5)
      expect(actual[0]).to eq(title: '2015-09', id: 'tab201509', class: nil)
      expect(actual[1]).to eq(title: '2015-10', id: 'tab201510', class: 'active')
      expect(actual[2]).to eq(title: '2015-11', id: 'tab201511', class: nil)
      expect(actual[3]).to eq(title: '2015-12', id: 'tab201512', class: nil)
      expect(actual[4]).to eq(title: '2016-01', id: 'tab201601', class: nil)
    end
  end

  describe '#journal_list_from_tab_name' do
    let(:fiscal_year) { create(:fiscal_year, date_from: Date.new(2015, 9, 1), date_to: Date.new(2016, 1, 15)) }

    example 'get' do
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 11, 1), comment: '対象外')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 31), comment: '2')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 1), comment: '1')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 9, 30), comment: '対象外')

      actual = JournalsService.journal_list_from_tab_name('tab201510', fiscal_year)
      expect(actual.length).to eq(2)
      expect(actual[0]).to have_attributes(journal_date: Date.new(2015, 10, 1), comment: '1')
      expect(actual[1]).to have_attributes(journal_date: Date.new(2015, 10, 31), comment: '2')
    end
  end

  describe '#get_subject_list_with_usage_ranking' do
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
      actual = JournalsService.get_subject_list_with_usage_ranking(fiscal_year, true)
      expect(actual.map(&:code)).to eq(%w(201 202 101 102))
      key = "JournalsService#get_subject_list_with_usage_ranking(#{fiscal_year.id}-debit)"
      from_cache = Rails.cache.fetch(key)
      expect(from_cache.map(&:code)).to eq(%w(201 202 101 102))
    end

    it 'get subjects for credit' do
      actual = JournalsService.get_subject_list_with_usage_ranking(fiscal_year, false)
      expect(actual.map(&:code)).to eq(%w(102 101 201 202))
      key = "JournalsService#get_subject_list_with_usage_ranking(#{fiscal_year.id}-credit)"
      from_cache = Rails.cache.fetch(key)
      expect(from_cache.map(&:code)).to eq(%w(102 101 201 202))
    end
  end

  describe '#get_subject_list' do
    let(:fiscal_year) { create(:fiscal_year) }

    before do
      create(:subject, fiscal_year: fiscal_year, code: '201')
      create(:subject, fiscal_year: fiscal_year, code: '202')
      create(:subject, fiscal_year: fiscal_year, code: '101')
      create(:subject, fiscal_year: fiscal_year, code: '102')
    end

    it 'with sort' do
      actual = JournalsService.get_subject_list(fiscal_year)
      expect(actual.map(&:code)).to eq(%w(101 102 201 202))
    end

    it 'without sort' do
      actual = JournalsService.get_subject_list(fiscal_year, false)
      expect(actual.map(&:code)).to eq(%w(201 202 101 102))
    end
  end
end
