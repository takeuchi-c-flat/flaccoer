require 'rails_helper'

RSpec.describe ReportsBlueExcelService do
  let(:fiscal_year) {
    create(
      :fiscal_year,
      date_from: Date.new(2015, 1, 1),
      date_to: Date.new(2015, 12, 31),
      title: '平成２７年度',
      organization_name: '組織名')
  }
  let(:type_property) { SubjectType.find_by(debit: true, debit_and_credit: true) }
  let(:type_loss) { SubjectType.find_by(debit: true, profit_and_loss: true) }
  let(:type_profit) { SubjectType.find_by(credit: true, profit_and_loss: true) }

  describe '#create_report1_excel_file' do
    example 'create' do
      tmp_file_name = 'tmp/月別売上仕入.xlsx'
      expect(ExcelService).to \
        receive(:create_workbook_from_template).
          with('sales_per_month.xlsx', tmp_file_name, '月別売上仕入').
          and_return('DUMMY_BOOK')
      expect(ExcelService).to \
        receive(:get_first_sheet).
          with('DUMMY_BOOK').
          and_return('DUMMY_SHEET')

      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 0, col: 7, contents: '平成２７年度 - 組織名' },
              { row: 2, col: 7, contents: '(自) 2015-01-01 (至) 2015-12-31' }
            ])

      subject301 = create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, report1_location: 1, code: '1')
      subject302 = create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, report1_location: 1, code: '2')
      subject392 = create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, report1_location: 2, code: '3')
      subject393 = create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, report1_location: 3, code: '4')
      subject401 = create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, report1_location: 4, code: '5')
      subject101 = create(:subject, fiscal_year: fiscal_year, subject_type: type_loss, report1_location: 0, code: '6')
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 1, 1),
        subject_debit: subject101, subject_credit: subject301, price: 1010000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 12, 1),
        subject_debit: subject101, subject_credit: subject301, price: 1130000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 12, 31),
        subject_debit: subject302, subject_credit: subject101, price: 10000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 4, 1),
        subject_debit: subject101, subject_credit: subject392, price: 200)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 4, 1),
        subject_debit: subject101, subject_credit: subject392, price: 20)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 4, 1),
        subject_debit: subject101, subject_credit: subject393, price: 300)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 1, 31),
        subject_debit: subject401, subject_credit: subject101, price: 10000)
      create(
        :journal,
        fiscal_year: fiscal_year, journal_date: Date.new(2015, 12, 31),
        subject_debit: subject401, subject_credit: subject101, price: 120000)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 5, col: 2, contents: 1010000 },
              { row: 6, col: 2, contents: 0 },
              { row: 7, col: 2, contents: 0 },
              { row: 8, col: 2, contents: 0 },
              { row: 9, col: 2, contents: 0 },
              { row: 10, col: 2, contents: 0 },
              { row: 11, col: 2, contents: 0 },
              { row: 12, col: 2, contents: 0 },
              { row: 13, col: 2, contents: 0 },
              { row: 14, col: 2, contents: 0 },
              { row: 15, col: 2, contents: 0 },
              { row: 16, col: 2, contents: 1120000 },
              { row: 17, col: 2, contents: 220 },
              { row: 18, col: 2, contents: 300 },
              { row: 5, col: 4, contents: 10000 },
              { row: 6, col: 4, contents: 0 },
              { row: 7, col: 4, contents: 0 },
              { row: 8, col: 4, contents: 0 },
              { row: 9, col: 4, contents: 0 },
              { row: 10, col: 4, contents: 0 },
              { row: 11, col: 4, contents: 0 },
              { row: 12, col: 4, contents: 0 },
              { row: 13, col: 4, contents: 0 },
              { row: 14, col: 4, contents: 0 },
              { row: 15, col: 4, contents: 0 },
              { row: 16, col: 4, contents: 120000 }
            ])

      expect(ExcelService).to receive(:write_workbook).with('DUMMY_BOOK').and_return(tmp_file_name)

      expect(ReportsBlueExcelService.create_report1_excel_file(fiscal_year)).to eq(tmp_file_name)
    end
  end
end
