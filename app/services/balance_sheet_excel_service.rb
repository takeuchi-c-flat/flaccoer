require 'rubyXL'

module BalanceSheetExcelService
  module_function

  TEMPLATE_FILE_NAME = 'balance_sheet.xlsx'
  DETAIL_START_ROW_INDEX = 6
  ODD_COLOR = 'eeeeee'
  SUMMARY_COLOR = 'ddffdd'
  TITLES = [
    { type: true, title: '貸借対照表', section1: '資産の部', section2: '負債・資本の部' },
    { type: false, title: '損益計算書', section1: '支出の部', section2: '収入の部' }
  ]
  COL_START_VALUES = [1, 7]

  # 合計残高試算表のExcelファイルを生成して、ファイル名を返します。
  def create_excel_file(fiscal_year, date_from, date_to, is_balance_sheet)
    sheet_name = get_title_info(is_balance_sheet)[:title]
    temp_file_name = ExcelService.create_temp_file_name("#{sheet_name}.xlsx")
    workbook = ExcelService.create_workbook_from_template(TEMPLATE_FILE_NAME, temp_file_name, sheet_name)
    sheet = ExcelService.get_first_sheet(workbook)
    format(sheet, fiscal_year, date_from, date_to, is_balance_sheet)
    ExcelService.write_workbook(workbook)
  end

  # タイトル情報を取得します。
  def get_title_info(is_balance_sheet)
    TITLES.find { |t| t[:type] == is_balance_sheet }
  end

  # 帳票を編集します。
  def format(sheet, fiscal_year, date_from, date_to, is_balance_sheet)
    # ヘッダ部の編集
    format_header_contents(sheet, fiscal_year, date_from, date_to, get_title_info(is_balance_sheet))

    # 明細の編集
    list = if is_balance_sheet
             BalanceSheetService.get_balance_sheet_list_debit_and_credit(fiscal_year, date_from, date_to)
           else
             BalanceSheetService.get_balance_sheet_list_profit_and_loss(fiscal_year, date_from, date_to)
           end
    format_detail_contents(sheet, list)

    # 合計行の編集
    format_summary_contents(sheet, list)
  end

  # ヘッダ部の編集
  def format_header_contents(sheet, fiscal_year, date_from, date_to, title_hash)
    from = date_from.strftime('%_m月%e日') + (date_from == fiscal_year.date_from ? '(期首)' : '')
    to = date_to.strftime('%_m月%e日') + (date_to == fiscal_year.date_to ? '(期末)' : '')
    contents_list = [
      { row: 0, col: 1, contents: title_hash[:title] },
      { row: 0, col: 11, contents: fiscal_year.select_box_name },
      { row: 2, col: 11, contents: "(自) #{date_from.strftime('%Y-%m-%d')} (至) #{date_to.strftime('%Y-%m-%d')}" },
      { row: 4, col: 2, contents: title_hash[:section1] },
      { row: 4, col: 8, contents: title_hash[:section2] },
      { row: 5, col: 3, contents: from },
      { row: 5, col: 5, contents: to },
      { row: 5, col: 9, contents: from },
      { row: 5, col: 11, contents: to }
    ]
    ExcelService.set_cells_value(sheet, contents_list)
  end

  # 明細行の編集
  def format_detail_contents(sheet, list)
    row = DETAIL_START_ROW_INDEX
    list.each_with_index { |items, row_index|
      items.each_with_index { |item, section_index|
        start = COL_START_VALUES[section_index]
        contents_list = [
          { row: row, col: 0 + start, contents: item.code },
          { row: row, col: 1 + start, contents: item.name },
          { row: row, col: 2 + start, contents: item.carried },
          { row: row, col: 3 + start, contents: item.total },
          { row: row, col: 4 + start, contents: item.last_balance }
        ]
        ExcelService.set_row_fill_color(sheet, row, ODD_COLOR, start, start + 4) if row_index.odd?
        ExcelService.set_cells_value(sheet, contents_list)
      }
      row += 1
    }
  end

  # 合計行の編集
  def format_summary_contents(sheet, list)
    (0..1).each { |section_index|
      item = summary_balance_sheet(list, section_index)
      start = COL_START_VALUES[section_index]
      row = DETAIL_START_ROW_INDEX + list.length
      contents_list = [
        { row: row, col: 1 + start, contents: '【合　　計】' },
        { row: row, col: 2 + start, contents: item.carried },
        { row: row, col: 3 + start, contents: item.total },
        { row: row, col: 4 + start, contents: item.last_balance }
      ]
      ExcelService.set_row_fill_color(sheet, row, SUMMARY_COLOR, start, start + 4)
      ExcelService.set_cells_value(sheet, contents_list)
    }
  end

  # 合計を集計
  def summary_balance_sheet(list, part_index)
    part_list = list.map { |items| items[part_index] }
    BalanceSheet.new.tap { |m|
      m.carried = part_list.map(&:carried).compact.inject(:+) || 0
      m.total = part_list.map(&:total).compact.inject(:+) || 0
      m.last_balance = part_list.map(&:last_balance).compact.inject(:+) || 0
    }
  end
end
