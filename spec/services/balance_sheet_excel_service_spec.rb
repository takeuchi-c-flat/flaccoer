require 'rails_helper'

RSpec.describe BalanceSheetExcelService do
  let(:fiscal_year) {
    create(
      :fiscal_year,
      date_from: Date.new(2015, 1, 1),
      date_to: Date.new(2015, 12, 31),
      title: '平成２７年度',
      organization_name: '組織名')
  }

  describe '#create_excel_file' do
    example 'get balance_sheet and full_date_span' do
      date_from = Date.new(2015, 1, 1)
      date_to = Date.new(2015, 12, 31)
      tmp_file_name = 'tmp/貸借対照表.xlsx'
      expect(ExcelService).to \
        receive(:create_workbook_from_template).
          with('balance_sheet.xlsx', tmp_file_name, '貸借対照表').
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
              { row: 0, col: 1, contents: '貸借対照表' },
              { row: 0, col: 11, contents: '平成２７年度 - 組織名' },
              { row: 2, col: 11, contents: '(自) 2015-01-01 (至) 2015-12-31' },
              { row: 4, col: 2, contents: '資産の部' },
              { row: 4, col: 8, contents: '負債・資本の部' },
              { row: 5, col: 3, contents: ' 1月 1日(期首)' },
              { row: 5, col: 5, contents: '12月31日(期末)' },
              { row: 5, col: 9, contents: ' 1月 1日(期首)' },
              { row: 5, col: 11, contents: '12月31日(期末)' }
            ])
      list = [
        [
          BalanceSheet.from_subject_and_journal_summary(create(:subject, code: '101', name: '科目101'), 4000, 0, 400),
          BalanceSheet.from_subject_and_journal_summary(create(:subject, code: '201', name: '科目201'), 4000, 0, 100)
        ],
        [
          BalanceSheet.new,
          BalanceSheet.new.tap { |m|
            m.name = '＊＊剰余金＊＊'
            m.carried = 0
            m.total = 300
            m.last_balance = 300
          }
        ]
      ]
      expect(BalanceSheetService).to \
        receive(:get_balance_sheet_list_debit_and_credit).
          with(fiscal_year, date_from, date_to).
          and_return(list)

      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 6, col: 1, contents: '101' },
              { row: 6, col: 2, contents: '科目101' },
              { row: 6, col: 3, contents: 4000 },
              { row: 6, col: 4, contents: 400 },
              { row: 6, col: 5, contents: 4400 }
            ])
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 6, col: 7, contents: '201' },
              { row: 6, col: 8, contents: '科目201' },
              { row: 6, col: 9, contents: 4000 },
              { row: 6, col: 10, contents: 100 },
              { row: 6, col: 11, contents: 4100 }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 7, 'eeeeee', 1, 5)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 7, col: 1, contents: nil },
              { row: 7, col: 2, contents: nil },
              { row: 7, col: 3, contents: nil },
              { row: 7, col: 4, contents: nil },
              { row: 7, col: 5, contents: nil }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 7, 'eeeeee', 7, 11)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 7, col: 7, contents: nil },
              { row: 7, col: 8, contents: '＊＊剰余金＊＊' },
              { row: 7, col: 9, contents: 0 },
              { row: 7, col: 10, contents: 300 },
              { row: 7, col: 11, contents: 300 }
            ])

      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 8, 'ddffdd', 1, 5)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 8, col: 2, contents: '【合　　計】' },
              { row: 8, col: 3, contents: 4000 },
              { row: 8, col: 4, contents: 400 },
              { row: 8, col: 5, contents: 4400 }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 8, 'ddffdd', 7, 11)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 8, col: 8, contents: '【合　　計】' },
              { row: 8, col: 9, contents: 4000 },
              { row: 8, col: 10, contents: 400 },
              { row: 8, col: 11, contents: 4400 }
            ])

      expect(ExcelService).to receive(:write_workbook).with('DUMMY_BOOK').and_return(tmp_file_name)

      expect(BalanceSheetExcelService.create_excel_file(fiscal_year, date_from, date_to, true)).to eq(tmp_file_name)
    end

    example 'get profit_and_loss_sheet and not_full_date_span' do
      date_from = Date.new(2015, 2, 1)
      date_to = Date.new(2015, 11, 30)
      tmp_file_name = 'tmp/損益計算書.xlsx'
      expect(ExcelService).to \
        receive(:create_workbook_from_template).
          with('balance_sheet.xlsx', tmp_file_name, '損益計算書').
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
              { row: 0, col: 1, contents: '損益計算書' },
              { row: 0, col: 11, contents: '平成２７年度 - 組織名' },
              { row: 2, col: 11, contents: '(自) 2015-02-01 (至) 2015-11-30' },
              { row: 4, col: 2, contents: '支出の部' },
              { row: 4, col: 8, contents: '収入の部' },
              { row: 5, col: 3, contents: ' 2月 1日' },
              { row: 5, col: 5, contents: '11月30日' },
              { row: 5, col: 9, contents: ' 2月 1日' },
              { row: 5, col: 11, contents: '11月30日' }
            ])
      list = [
        [
          BalanceSheet.new.tap { |m|
            m.name = '＊＊剰余金＊＊'
            m.carried = 2000
            m.total = 300
            m.last_balance = 2300
          },
          BalanceSheet.from_subject_and_journal_summary(create(:subject, code: '301', name: '科目301'), 500, 1500, 300)
        ]
      ]
      expect(BalanceSheetService).to \
        receive(:get_balance_sheet_list_profit_and_loss).
          with(fiscal_year, date_from, date_to).
          and_return(list)

      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 6, col: 1, contents: nil },
              { row: 6, col: 2, contents: '＊＊剰余金＊＊' },
              { row: 6, col: 3, contents: 2000 },
              { row: 6, col: 4, contents: 300 },
              { row: 6, col: 5, contents: 2300 }
            ])
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 6, col: 7, contents: '301' },
              { row: 6, col: 8, contents: '科目301' },
              { row: 6, col: 9, contents: 2000 },
              { row: 6, col: 10, contents: 300 },
              { row: 6, col: 11, contents: 2300 }
            ])

      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 7, 'ddffdd', 1, 5)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 7, col: 2, contents: '【合　　計】' },
              { row: 7, col: 3, contents: 2000 },
              { row: 7, col: 4, contents: 300 },
              { row: 7, col: 5, contents: 2300 }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 7, 'ddffdd', 7, 11)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 7, col: 8, contents: '【合　　計】' },
              { row: 7, col: 9, contents: 2000 },
              { row: 7, col: 10, contents: 300 },
              { row: 7, col: 11, contents: 2300 }
            ])

      expect(ExcelService).to receive(:write_workbook).with('DUMMY_BOOK').and_return(tmp_file_name)

      expect(BalanceSheetExcelService.create_excel_file(fiscal_year, date_from, date_to, false)).to eq(tmp_file_name)
    end
  end
end
