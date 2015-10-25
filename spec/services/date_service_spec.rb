require 'rails_helper'

RSpec.describe DateService do
  describe '#enumerate_months_from_date_span' do
    example 'enumerate OK' do
      actual1 = DateService.enumerate_months_from_date_span(Date.new(2015, 1, 3), Date.new(2015, 1, 30))
      expect(actual1).to eq([Date.new(2015, 1, 1)])
      actual2 = DateService.enumerate_months_from_date_span(Date.new(2015, 1, 1), Date.new(2016, 6, 30))
      expect(actual2.length).to eq(18)
      expect(actual2.first).to eq(Date.new(2015, 1, 1))
      expect(actual2.last).to eq(Date.new(2016, 6, 1))
    end

    example 'enumerate NG' do
      expect(DateService.enumerate_months_from_date_span(Date.new(2015, 1, 1), Date.new(2014, 12, 31))).to eq([])
    end
  end

  describe '#months_count_from_date_span' do
    example 'enumerate OK' do
      actual1 = DateService.months_count_from_date_span(Date.new(2015, 1, 3), Date.new(2015, 1, 30))
      expect(actual1).to eq(1)
      actual2 = DateService.months_count_from_date_span(Date.new(2015, 1, 1), Date.new(2016, 6, 30))
      expect(actual2).to eq(18)
    end

    example 'enumerate NG' do
      expect(DateService.months_count_from_date_span(Date.new(2015, 1, 1), Date.new(2014, 12, 31))).to eq(0)
    end
  end

  describe '#validate_date_order' do
    example 'validate OK' do
      expect(DateService.validate_date_order(Date.new(2015, 1, 1), Date.new(2015, 1, 1))).to eq(true)
      expect(DateService.validate_date_order(Date.new(2015, 1, 1), Date.new(2015, 1, 2))).to eq(true)
      expect(DateService.validate_date_order(Date.new(2015, 1, 1), Date.new(2016, 6, 30))).to eq(true)
    end

    example 'validate NG' do
      expect(DateService.validate_date_order(Date.new(2015, 1, 1), Date.new(2014, 12, 31))).to eq(false)
    end
  end

  describe '#date_range_from_year_month' do
    example 'get' do
      expect(DateService.date_range_from_year_month('201512')).to eq([Date.new(2015, 12, 1), Date.new(2015, 12, 31)])
    end
  end
end
