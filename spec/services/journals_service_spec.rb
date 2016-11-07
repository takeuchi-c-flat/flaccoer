require 'rails_helper'

RSpec.describe JournalsService do
  describe '#create_journal_months' do
    example 'create per 1month' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 9, 1),
        date_to: Date.new(2016, 1, 15))

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 10, 15))
      expect(actual.length).to eq(5)
      expect(actual[0]).to eq(title: '2015-09', id: 'tab201509', class: nil)
      expect(actual[1]).to eq(title: '2015-10', id: 'tab201510', class: 'active')
      expect(actual[2]).to eq(title: '2015-11', id: 'tab201511', class: nil)
      expect(actual[3]).to eq(title: '2015-12', id: 'tab201512', class: nil)
      expect(actual[4]).to eq(title: '2016-01', id: 'tab201601', class: nil)
    end

    example 'create per 2months' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 9, 1),
        date_to: Date.new(2015, 12, 31),
        tab_type: 1)

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 11, 15))
      expect(actual.length).to eq(3)
      expect(actual[0]).to eq(title: '2015-09〜10', id: 'tab201509-201510', class: nil)
      expect(actual[1]).to eq(title: '2015-11〜12', id: 'tab201511-201512', class: nil)
      expect(actual[2]).to eq(title: '直近2ヶ月', id: 'tabLast201510-201511', class: 'active')
    end

    example 'create per 2months month count is odd' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 8, 1),
        date_to: Date.new(2015, 12, 31),
        tab_type: 1)

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 11, 15))
      expect(actual.length).to eq(4)
      expect(actual[0]).to eq(title: '2015-08〜09', id: 'tab201508-201509', class: nil)
      expect(actual[1]).to eq(title: '2015-10〜11', id: 'tab201510-201511', class: nil)
      expect(actual[2]).to eq(title: '2015-12', id: 'tab201512-201512', class: nil)
      expect(actual[3]).to eq(title: '直近2ヶ月', id: 'tabLast201510-201511', class: 'active')
    end

    example 'create per 2months month count is one' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 8, 1),
        date_to: Date.new(2015, 8, 31),
        tab_type: 1)

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 8, 15))
      expect(actual.length).to eq(1)
      expect(actual[0]).to eq(title: '2015-08', id: 'tab201508-201508', class: 'active')
    end

    example 'create per 2months at first month' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 9, 1),
        date_to: Date.new(2015, 12, 31),
        tab_type: 1)

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 9, 4))
      expect(actual.length).to eq(2)
      expect(actual[0]).to eq(title: '2015-09〜10', id: 'tab201509-201510', class: 'active')
      expect(actual[1]).to eq(title: '2015-11〜12', id: 'tab201511-201512', class: nil)
    end

    example 'create all months' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 8, 1),
        date_to: Date.new(2016, 1, 31),
        tab_type: 2)

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 11, 15))
      expect(actual.length).to eq(1)
      expect(actual[0]).to eq(title: '仕訳一覧', id: 'tabAll201508-201601', class: 'active')
    end


    example 'create all months month count is one' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 8, 1),
        date_to: Date.new(2015, 8, 31),
        tab_type: 2)

      actual = JournalsService.create_journal_months(fiscal_year, Date.new(2015, 8, 15))
      expect(actual.length).to eq(1)
      expect(actual[0]).to eq(title: '仕訳一覧', id: 'tabAll201508-201508', class: 'active')
    end
  end

  describe '#journal_list_from_tab_name' do
    example 'get single month asc' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 9, 1),
        date_to: Date.new(2016, 1, 15))

      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 11, 1), comment: '対象外')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 31), comment: '2')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 1), comment: '1')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 9, 30), comment: '対象外')

      actual = JournalsService.journal_list_from_tab_name('tabLast201510', fiscal_year)
      expect(actual.length).to eq(2)
      expect(actual[0]).to have_attributes(journal_date: Date.new(2015, 10, 1), comment: '1')
      expect(actual[1]).to have_attributes(journal_date: Date.new(2015, 10, 31), comment: '2')
    end

    example 'get asc' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 9, 1),
        date_to: Date.new(2016, 1, 15))

      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 12, 1), comment: '対象外')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 11, 30), comment: '3')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 31), comment: '2')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 1), comment: '1')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 9, 30), comment: '対象外')

      actual = JournalsService.journal_list_from_tab_name('tabLast201510-201511', fiscal_year)
      expect(actual.length).to eq(3)
      expect(actual[0]).to have_attributes(journal_date: Date.new(2015, 10, 1), comment: '1')
      expect(actual[1]).to have_attributes(journal_date: Date.new(2015, 10, 31), comment: '2')
      expect(actual[2]).to have_attributes(journal_date: Date.new(2015, 11, 30), comment: '3')
    end

    example 'get desc' do
      fiscal_year = create(
        :fiscal_year,
        date_from: Date.new(2015, 9, 1),
        date_to: Date.new(2016, 1, 15),
        list_desc: true)

      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 11, 1), comment: '対象外')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 31), comment: '2')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 1), comment: '1')
      create(:journal, fiscal_year: fiscal_year, journal_date: Date.new(2015, 9, 30), comment: '対象外')

      actual = JournalsService.journal_list_from_tab_name('tab201510-201510', fiscal_year)
      expect(actual.length).to eq(2)
      expect(actual[0]).to have_attributes(journal_date: Date.new(2015, 10, 31), comment: '2')
      expect(actual[1]).to have_attributes(journal_date: Date.new(2015, 10, 1), comment: '1')
    end
  end
end
