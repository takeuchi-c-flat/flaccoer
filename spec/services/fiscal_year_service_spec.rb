require 'rails_helper'

RSpec.describe FiscalYearService do
  describe '#accessible_fiscal_years' do
    example 'only my_fiscal_year' do
      user = create(:user)
      year1 = FactoryGirl.create(
        :fiscal_year,
        user: user,
        title: '年度１',
        date_from: Date.new(2015, 4, 1),
        date_to: Date.new(2016, 3, 31))
      year2 = FactoryGirl.create(
        :fiscal_year,
        user: user,
        title: '年度１',
        date_from: Date.new(2016, 4, 1),
        date_to: Date.new(2017, 3, 31))
      expect(FiscalYearService.accessible_fiscal_years(user)).to eq([year2, year1])
    end

    # TODO: with permitted_fiscal_year pattern
  end

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

  describe '#subjects_from_template' do
    example 'create_subjects' do
      template_type = create(:subject_template_type)
      subject_type = create(:subject_type)
      [
        { code: '001', name: '科目１', loc1: 101, loc2: 201, loc3: 301 },
        { code: '002', name: '科目２', loc4: 402, loc5: 502 },
        { code: '003', name: '科目３' }
      ].each { |hash|
        FactoryGirl.create(
          :subject_template,
          subject_template_type: template_type,
          subject_type: subject_type,
          code: hash[:code],
          name: hash[:name],
          report1_location: hash[:loc1],
          report2_location: hash[:loc2],
          report3_location: hash[:loc3],
          report4_location: hash[:loc4],
          report5_location: hash[:loc5]
        )
      }
      new_fiscal_year = create(:fiscal_year)

      actual = FiscalYearService.subjects_from_template(template_type, new_fiscal_year)
      expect(actual.length).to eq(3)
      expect(actual[0]).to have_attributes(
        fiscal_year: new_fiscal_year,
        subject_type: subject_type,
        code: '001',
        name: '科目１',
        report1_location: 101,
        report2_location: 201,
        report3_location: 301,
        from_template: true)
      expect(actual[1]).to have_attributes(
        fiscal_year: new_fiscal_year,
        code: '002',
        report4_location: 402,
        report5_location: 502,
        from_template: true)
      expect(actual[2]).to have_attributes(
        fiscal_year: new_fiscal_year,
        code: '003',
        from_template: true)
    end
  end

  describe '#subjects_from_base_fiscal_year' do
    example 'create_subjects' do
      base_fiscal_year = create(:fiscal_year)
      new_fiscal_year = create(:fiscal_year)
      subject_type = create(:subject_type)
      [
        { code: '001', name: '科目１', from_template: true, loc1: 101, loc2: 201, loc3: 301 },
        { code: '002', name: '科目２', from_template: true, loc4: 402, loc5: 502 },
        { code: '003', name: '科目３', from_template: false }
      ].each { |hash|
        FactoryGirl.create(
          :subject,
          fiscal_year: base_fiscal_year,
          subject_type: subject_type,
          code: hash[:code],
          name: hash[:name],
          report1_location: hash[:loc1],
          report2_location: hash[:loc2],
          report3_location: hash[:loc3],
          report4_location: hash[:loc4],
          report5_location: hash[:loc5],
          from_template: hash[:from_template]
        )
      }

      actual = FiscalYearService.subjects_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
      expect(actual.length).to eq(3)
      expect(actual[0]).to have_attributes(
        fiscal_year: new_fiscal_year,
        subject_type: subject_type,
        code: '001',
        name: '科目１',
        report1_location: 101,
        report2_location: 201,
        report3_location: 301,
        from_template: true)
      expect(actual[1]).to have_attributes(
        fiscal_year: new_fiscal_year,
        code: '002',
        report4_location: 402,
        report5_location: 502,
        from_template: true)
      expect(actual[2]).to have_attributes(
        fiscal_year: new_fiscal_year,
        code: '003',
        from_template: false)
    end
  end

  describe '#fiscal_year_can_delete?' do
    let(:fiscal_year) { create(:fiscal_year) }

    example 'delete OK' do
      expect(FiscalYearService.fiscal_year_can_delete?(fiscal_year)).to eq(true)
    end

    example 'delete NG (with Journal)' do
      FactoryGirl.create(:journal, fiscal_year: fiscal_year)
      expect(FiscalYearService.fiscal_year_can_delete?(fiscal_year)).to eq(false)
    end

    example 'delete NG (with Balance)' do
      FactoryGirl.create(:balance, fiscal_year: fiscal_year)
      expect(FiscalYearService.fiscal_year_can_delete?(fiscal_year)).to eq(false)
    end

    example 'delete NG (with Badget)' do
      FactoryGirl.create(:badget, fiscal_year: fiscal_year)
      expect(FiscalYearService.fiscal_year_can_delete?(fiscal_year)).to eq(false)
    end
  end

  describe '#get_subjects_by_fiscal_year' do
    let(:fiscal_year) { create(:fiscal_year) }

    example 'get' do
      subject1 = FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '101A')
      subject2 = FactoryGirl.create(:subject, fiscal_year: fiscal_year, code: '101B')

      expect(FiscalYearService.get_subjects_by_fiscal_year(fiscal_year)).to eq([subject1, subject2])
    end
  end

  describe '#adjust_journal_date' do
    let(:fiscal_year) {
      FactoryGirl.create(
        :fiscal_year,
        date_from: Date.new(2016, 1, 1),
        date_to: Date.new(2016, 6, 30)
      )
    }

    example 'without FiscalYear' do
      today = Date.new(2016, 11, 1)
      allow(Date).to receive(:today).and_return(today)
      expect(FiscalYearService.adjust_journal_date(Date.new(2016, 1, 1), nil)).to eq(today)
    end

    example 'between FiscalYear date range' do
      expect(FiscalYearService.adjust_journal_date(Date.new(2016, 1, 1), fiscal_year)).to eq(Date.new(2016, 1, 1))
      expect(FiscalYearService.adjust_journal_date(Date.new(2016, 6, 30), fiscal_year)).to eq(Date.new(2016, 6, 30))
    end

    example 'not between FiscalYear date range' do
      expect(FiscalYearService.adjust_journal_date(Date.new(2015, 12, 31), fiscal_year)).to eq(Date.new(2016, 1, 1))
      expect(FiscalYearService.adjust_journal_date(Date.new(2016, 7, 1), fiscal_year)).to eq(Date.new(2016, 6, 30))
    end
  end
end
