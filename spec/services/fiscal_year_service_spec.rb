require 'rails_helper'

RSpec.describe FiscalYearService do
  describe '#validate_months_range' do
    example 'validate OK' do
      expect(FiscalYearService.validate_months_range(Date.new(2015, 1, 1), Date.new(2015, 12, 31))).to eq(true)
      expect(FiscalYearService.validate_months_range(Date.new(2015, 1, 1), Date.new(2016, 6, 30))).to eq(true)
    end

    example 'validate NG' do
      expect(FiscalYearService.validate_months_range(Date.new(2015, 1, 1), Date.new(2016, 7, 1))).to eq(false)
      expect(FiscalYearService.validate_months_range(Date.new(2015, 1, 31), Date.new(2016, 7, 1))).to eq(false)
    end
  end

  describe '#validate_journal_date' do
    let(:fiscal_year) { create(:fiscal_year) }

    example 'validate OK' do
      expect(FiscalYearService.validate_journal_date(fiscal_year, Date.new(2015, 1, 1))).to eq(true)
      expect(FiscalYearService.validate_journal_date(fiscal_year, Date.new(2015, 12, 31))).to eq(true)
    end

    example 'validate NG' do
      expect(FiscalYearService.validate_journal_date(fiscal_year, Date.new(2014, 12, 31))).to eq(false)
      expect(FiscalYearService.validate_journal_date(fiscal_year, Date.new(2016, 1, 1))).to eq(false)
    end
  end
end
