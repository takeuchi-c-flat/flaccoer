require 'rubyXL'

module LedgerExcelService
  module_function

  TEMPLATE_FILE_NAME = 'ledger.xlsx'
  DETAIL_START_ROW_INDEX = 6
  MIN_COL_INDEX = 1
  MAX_COL_INDEX = 7
  ODD_COLOR = 'eeeeee'

  # 総勘定元帳のExcelファイルを生成して、ファイル名を返します。
  def get_ledger_excel_file(fiscal_year, subject, date_from, date_to)
    sheet_name = "#{subject.code}-#{subject.name}"
    temp_file_name = ExcelService.create_temp_file_name("総勘定元帳_#{sheet_name}.xlsx")
    workbook = ExcelService.create_workbook_from_template(TEMPLATE_FILE_NAME, temp_file_name, sheet_name)
    sheet = ExcelService.get_first_sheet(workbook)
    format_subject_ledger(sheet, fiscal_year, subject, date_from, date_to)
    ExcelService.write_workbook(workbook)
  end

  # 総勘定元帳を編集します。
  def format_subject_ledger(sheet, fiscal_year, subject, date_from, date_to)
    # ヘッダ部の編集
    format_header_contents(sheet, fiscal_year, subject, date_from, date_to)

    # 残高の編集
    carried_balance = LedgerService.get_ledger_carried_balance(fiscal_year, subject, date_from)
    format_balance_contents(sheet, carried_balance)

    # 明細の編集
    journal_list = LedgerService.get_ledger_list(fiscal_year, subject, date_from, date_to, carried_balance)
    format_detail_contents(sheet, journal_list)
  end

  # ヘッダ部の編集
  def format_header_contents(sheet, fiscal_year, subject, date_from, date_to)
    contents_list = [
      { row: 0, col: 7, contents: fiscal_year.organization_name },
      { row: 2, col: 7, contents: "(自) #{date_from.strftime('%Y-%m-%d')} (至) #{date_to.strftime('%Y-%m-%d')}" },
      { row: 2, col: 2, contents: subject.code },
      { row: 2, col: 3, contents: subject.name }
    ]
    ExcelService.set_cells_value(sheet, contents_list)
  end

  # 残高行の編集
  def format_balance_contents(sheet, carried_balance)
    ExcelService.set_cells_value(sheet, [{ row: 5, col: 7, contents: carried_balance }])
  end

  # 明細行の編集
  def format_detail_contents(sheet, journal_list)
    # 明細を編集します。
    row = DETAIL_START_ROW_INDEX
    journal_list.each_with_index { |journal, index|
      contents_list = [
        { row: row, col: 1, contents: journal.journal_date.strftime('%Y-%m-%d') },
        { row: row, col: 2, contents: journal.ledger_subject.code },
        { row: row, col: 3, contents: journal.ledger_subject.name },
        { row: row, col: 4, contents: journal.comment },
        { row: row, col: 5, contents: journal.price_debit },
        { row: row, col: 6, contents: journal.price_credit },
        { row: row, col: 7, contents: journal.balance }
      ]
      ExcelService.set_row_fill_color(sheet, row, ODD_COLOR, MIN_COL_INDEX, MAX_COL_INDEX) if index.odd?
      ExcelService.set_cells_value(sheet, contents_list)
      row += 1
    }
  end
end
