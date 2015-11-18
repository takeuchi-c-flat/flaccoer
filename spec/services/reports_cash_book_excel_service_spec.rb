require 'rails_helper'

RSpec.describe ReportsCashBookExcelService do
  let(:fiscal_year) {
    create(
      :fiscal_year,
      date_from: Date.new(2015, 7, 1),
      date_to: Date.new(2015, 12, 31),
      title: '平成２７年度',
      organization_name: '組織名')
  }
  let(:single) { AccountType.find_by(code: 'SINGLE') }
  let(:type_property) { SubjectType.find_by(account_type: single, name: '現預金') }
  let(:type_profit) { SubjectType.find_by(account_type: single, name: '収入の部') }
  let(:type_loss) { SubjectType.find_by(account_type: single, name: '支出の部') }
  let(:subject1) {
    create(
      :subject,
      fiscal_year: fiscal_year, subject_type: type_property, code: '101', name: '現金',
      report1_location: 1)
  }
  let(:subject2) {
    create(
      :subject,
      fiscal_year: fiscal_year, subject_type: type_property, code: '102', name: '預金',
      report1_location: 2)
  }
  let(:subject3) { create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, code: '399', name: '雑収入') }
  let(:subject4) { create(:subject, fiscal_year: fiscal_year, subject_type: type_profit, code: '499', name: '雑損') }
  let(:journal_list) {
    [
      # 現預金の移動
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 7, 2),
        subject_debit: subject1, subject_credit: subject2, price: 100000, comment: '現金＜ー預金'),
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 7, 3),
        subject_debit: subject2, subject_credit: subject1, price: 5000, comment: '預金＜ー現金'),
      # 現金から支出
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 8, 1),
        subject_debit: subject4, subject_credit: subject1, price: 10000, comment: '雑損＜ー現金'),
      # 預金へ収入
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 12, 31),
        subject_debit: subject2, subject_credit: subject3, price: 20000, comment: '預金＜ー雑収入'),
      # 関係ない仕訳(出納帳では原則的にはNG)
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 12, 31),
        subject_debit: subject4, subject_credit: subject3, price: 999, comment: '関係ない明細')
    ]
  }

  describe '#create_excel_file' do
    before do
      create(:balance, subject: subject1, top_balance: 150000)
      create(:balance, subject: subject2, top_balance: 1200000)

      # 現預金の移動
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 7, 2),
        subject_debit: subject1, subject_credit: subject2, price: 100000, comment: '現金＜ー預金')
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 7, 3),
        subject_debit: subject2, subject_credit: subject1, price: 5000, comment: '預金＜ー現金')
      # 現金から支出
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 8, 1),
        subject_debit: subject4, subject_credit: subject1, price: 10000, comment: '雑損＜ー現金')
      # 預金へ収入
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 12, 31),
        subject_debit: subject2, subject_credit: subject3, price: 20000, comment: '預金＜ー雑収入')
      # 関係ない仕訳(出納帳では原則的にはNG)
      create(
        :journal,
        fiscal_year: fiscal_year,
        journal_date: Date.new(2015, 12, 31),
        subject_debit: subject4, subject_credit: subject3, price: 999, comment: '関係ない明細')
    end

    example 'get' do
      tmp_file_name = 'tmp/現預金出納帳.xlsx'
      expect(ExcelService).to \
        receive(:create_workbook_from_template).
          with('cash_book.xlsx', tmp_file_name, '現預金出納帳').
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
              { row: 0, col: 8, contents: '平成２７年度 - 組織名' },
              { row: 2, col: 8, contents: '(自) 2015-07-01 (至) 2015-12-31' },
              { row: 4, col: 5, contents: '現金' },
              { row: 4, col: 7, contents: '預金' }
            ])

      expect(ExcelService).to \
        receive(:set_cells_value).with(
          'DUMMY_SHEET',
          [
            { row: 6, col: 6, contents: 150000 },
            { row: 6, col: 8, contents: 1200000 }
          ])

      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 7, col: 1, contents: '2015-07-02' },
              { row: 7, col: 2, contents: nil },
              { row: 7, col: 3, contents: nil },
              { row: 7, col: 4, contents: '現金＜ー預金' },
              { row: 7, col: 5, contents: 100000 },
              { row: 7, col: 6, contents: 250000 },
              { row: 7, col: 7, contents: -100000 },
              { row: 7, col: 8, contents: 1100000 }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 7, 'eeeeee', 1, 8)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 8, col: 1, contents: '2015-07-03' },
              { row: 8, col: 2, contents: nil },
              { row: 8, col: 3, contents: nil },
              { row: 8, col: 4, contents: '預金＜ー現金' },
              { row: 8, col: 5, contents: -5000 },
              { row: 8, col: 6, contents: 245000 },
              { row: 8, col: 7, contents: 5000 },
              { row: 8, col: 8, contents: 1105000 }
            ])
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 9, col: 1, contents: '2015-08-01' },
              { row: 9, col: 2, contents: '499' },
              { row: 9, col: 3, contents: '雑損' },
              { row: 9, col: 4, contents: '雑損＜ー現金' },
              { row: 9, col: 5, contents: -10000 },
              { row: 9, col: 6, contents: 235000 },
              { row: 9, col: 7, contents: 0 },
              { row: 9, col: 8, contents: 1105000 }
            ])
      expect(ExcelService).to receive(:set_row_fill_color).with('DUMMY_SHEET', 9, 'eeeeee', 1, 8)
      expect(ExcelService).to \
        receive(:set_cells_value).
          with(
            'DUMMY_SHEET',
            [
              { row: 10, col: 1, contents: '2015-12-31' },
              { row: 10, col: 2, contents: '399' },
              { row: 10, col: 3, contents: '雑収入' },
              { row: 10, col: 4, contents: '預金＜ー雑収入' },
              { row: 10, col: 5, contents: 0 },
              { row: 10, col: 6, contents: 235000 },
              { row: 10, col: 7, contents: 20000 },
              { row: 10, col: 8, contents: 1125000 }
            ])

      expect(ExcelService).to receive(:write_workbook).with('DUMMY_BOOK').and_return(tmp_file_name)

      expect(ReportsCashBookExcelService.create_report1_excel_file(fiscal_year)).to eq(tmp_file_name)
    end
  end
end
