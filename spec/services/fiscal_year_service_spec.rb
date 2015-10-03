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
end
