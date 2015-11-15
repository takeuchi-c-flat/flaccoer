require 'rubyXL'

module ReportsBlueExcelService
  module_function

  TEMPLATE_FILE_NAME_REPORT1 = 'sales_per_month.xlsx'
  REPORT1_MAPPING_TABLE = [
    { location: 1, row: 5, col: 2, per_month: true },
    { location: 2, row: 17, col: 2, per_month: false },
    { location: 3, row: 18, col: 2, per_month: false },
    { location: 4, row: 5, col: 4, per_month: true }
  ]

  # 月別売上のExcelファイルを生成して、ファイル名を返します。
  def create_report1_excel_file(fiscal_year)
    temp_file_name = ExcelService.create_temp_file_name('月別売上仕入.xlsx')
    workbook = ExcelService.create_workbook_from_template(TEMPLATE_FILE_NAME_REPORT1, temp_file_name, '月別売上仕入')
    sheet = ExcelService.get_first_sheet(workbook)
    format_report1(sheet, fiscal_year)
    ExcelService.write_workbook(workbook)
  end

  # 帳票を編集します。
  def format_report1(sheet, fiscal_year)
    format_report1_header_contents(sheet, fiscal_year)
    summary_list = get_report1_summary_list(fiscal_year)
    format_report1_detail_contents(sheet, summary_list)
  end

  # ヘッダ部の編集
  def format_report1_header_contents(sheet, fiscal_year)
    date_from = fiscal_year.date_from
    date_to = fiscal_year.date_to
    contents_list = [
      { row: 0, col: 7, contents: fiscal_year.select_box_name },
      { row: 2, col: 7, contents: "(自) #{date_from.strftime('%Y-%m-%d')} (至) #{date_to.strftime('%Y-%m-%d')}" }
    ]
    ExcelService.set_cells_value(sheet, contents_list)
  end

  # 明細行の集計データの取得
  def get_report1_summary_list(fiscal_year)
    REPORT1_MAPPING_TABLE.
      map { |table| table[:location] }.
      flat_map { |location|
        subjects = Subject.where(fiscal_year: fiscal_year, report1_location: location)
        subjects.flat_map { |subject| get_total_per_subject_and_month(fiscal_year, location, subject) }
      }
  end

  # 勘定科目・月別の発生金額を取得します。
  def get_total_per_subject_and_month(fiscal_year, location, subject)
    Journal.where(fiscal_year: fiscal_year).with_subjects.select_by_subject(subject).
      group_by { |m| m.journal_date.month }.
      map { |month, journals|
        total = journals.map { |m| m.price_for_balance(subject) }.inject(:+) || 0
        { location: location, month: month, total: total }
      }
  end

  # 明細行の編集
  def format_report1_detail_contents(sheet, summary_list)
    # 明細を編集します。
    contents_list = REPORT1_MAPPING_TABLE.flat_map { |map|
      summary = summary_list.select { |s| s[:location] == map[:location] }

      if map[:per_month]
        (1..12).flat_map { |month|
          total = summary.select { |s| s[:month] == month }.map { |s| s[:total] }.inject(:+) || 0
          { row: map[:row] + month - 1, col: map[:col], contents: total }
        }
      else
        total = summary.map { |s| s[:total] }.inject(:+) || 0
        { row: map[:row], col: map[:col], contents: total }
      end
    }
    ExcelService.set_cells_value(sheet, contents_list)
  end
end
