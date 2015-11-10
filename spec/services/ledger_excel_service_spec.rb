require 'rails_helper'

RSpec.describe LedgerExcelService do
  let(:fiscal_year) {
    create(
      :fiscal_year,
      date_from: Date.new(2015, 7, 1),
      date_to: Date.new(2015, 12, 31),
      title: '平成２７年度',
      organization_name: '組織名')
  }
  let(:subject) { create(:subject, fiscal_year: fiscal_year, code: '199', name: '科目199') }
  let(:subject1) { create(:subject, fiscal_year: fiscal_year, code: '101', name: '科目101') }
  let(:subject2) { create(:subject, fiscal_year: fiscal_year, code: '102', name: '科目102') }
  let(:journal_list) {
    [
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 8, 1),
        ledger_subject: subject1, comment: '明細１',
        price_debit: 100, price_credit: 0, balance: 10100),
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 12, 1),
        ledger_subject: subject2, comment: '明細２',
        price_debit: 0, price_credit: 500, balance: 9600),
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 12, 31),
        ledger_subject: subject2, comment: '明細３',
        price_debit: 10000, price_credit: 0, balance: 19600)
    ]
  }

  describe '#create_excel_file' do
    example 'get' do
      date_from = Date.new(2015, 8, 1)
      date_to = Date.new(2015, 12, 31)
      tmp_file_name = 'tmp/総勘定元帳_199-科目199.xlsx'
      expect(ExcelService).to \
        receive(:create_workbook_from_template).
          with('ledger.xlsx', tmp_file_name, '199-科目199').
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
              { row: 2, col: 7, contents: '(自) 2015-08-01 (至) 2015-12-31' },
              { row: 2, col: 2, contents: '199' },
              { row: 2, col: 3, contents: '科目199' }
            ])
      expect(LedgerService).to \
        receive(:get_ledger_carried_balance).with(fiscal_year, subject, date_from).and_return(10000)
      expect(ExcelService).to \
        receive(:set_cells_value).with('DUMMY_SHEET', [{ row: 5, col: 7, contents: 10000 }])

      expect(LedgerService).to \
        receive(:get_ledger_list).with(fiscal_year, subject, date_from, date_to, 10000).and_return(journal_list)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 6, col: 1, contents: '2015-08-01' },
              { row: 6, col: 2, contents: '101' },
              { row: 6, col: 3, contents: '科目101' },
              { row: 6, col: 4, contents: '明細１' },
              { row: 6, col: 5, contents: 100 },
              { row: 6, col: 6, contents: 0 },
              { row: 6, col: 7, contents: 10100 }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 7, 'eeeeee', 1, 7)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 7, col: 1, contents: '2015-12-01' },
              { row: 7, col: 2, contents: '102' },
              { row: 7, col: 3, contents: '科目102' },
              { row: 7, col: 4, contents: '明細２' },
              { row: 7, col: 5, contents: 0 },
              { row: 7, col: 6, contents: 500 },
              { row: 7, col: 7, contents: 9600 }
            ])
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 8, col: 1, contents: '2015-12-31' },
              { row: 8, col: 2, contents: '102' },
              { row: 8, col: 3, contents: '科目102' },
              { row: 8, col: 4, contents: '明細３' },
              { row: 8, col: 5, contents: 10000 },
              { row: 8, col: 6, contents: 0 },
              { row: 8, col: 7, contents: 19600 }
            ])

      expect(ExcelService).to receive(:write_workbook).with('DUMMY_BOOK').and_return(tmp_file_name)

      expect(LedgerExcelService.create_excel_file(fiscal_year, subject, date_from, date_to)).to eq(tmp_file_name)
    end
  end
end
