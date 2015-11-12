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
end
