require 'rubyXL'

module ReportsCashBookExcelService
  module_function

  REPORT1_TEMPLATE_FILE_NAME = 'cash_book.xlsx'
  REPORT1_DETAIL_START_ROW_INDEX = 7
  REPORT1_MIN_COL_INDEX = 1
  REPORT1_MAX_COL_INDEX = 8
  ODD_COLOR = 'eeeeee'

  # 月別売上のExcelファイルを生成して、ファイル名を返します。
  def create_report1_excel_file(fiscal_year)
    temp_file_name = ExcelService.create_temp_file_name('現預金出納帳.xlsx')
    workbook = ExcelService.create_workbook_from_template(REPORT1_TEMPLATE_FILE_NAME, temp_file_name, '現預金出納帳')
    sheet = ExcelService.get_first_sheet(workbook)
    format_report1(sheet, fiscal_year)
    ExcelService.write_workbook(workbook)
  end

  # 帳票を編集します。
  def format_report1(sheet, fiscal_year)
    all_subjects = Subject.eager_load(:subject_type, :balance).where(fiscal_year: fiscal_year)
    subjects_info = Report1SubjectsInfo.new(
      all_subjects.find_by(report1_location: 1),
      all_subjects.find_by(report1_location: 2))

    format_report1_header_contents(sheet, fiscal_year, subjects_info)
    set_top_balance(subjects_info)
    format_report1_carried_contents(sheet, subjects_info)
    cash_book_list = get_report1_detail_list(fiscal_year, subjects_info)
    format_report1_detail_contents(sheet, cash_book_list)
  end

  # ヘッダ部の編集
  def format_report1_header_contents(sheet, fiscal_year, subjects_info)
    date_from = fiscal_year.date_from
    date_to = fiscal_year.date_to
    contents_list = [
      { row: 0, col: 8, contents: fiscal_year.select_box_name },
      { row: 2, col: 8, contents: "(自) #{date_from.strftime('%Y-%m-%d')} (至) #{date_to.strftime('%Y-%m-%d')}" },
      { row: 4, col: 5, contents: subjects_info.subject1.try(&:to_s) },
      { row: 4, col: 7, contents: subjects_info.subject2.try(&:to_s) }
    ]
    ExcelService.set_cells_value(sheet, contents_list)
  end

  # 残高部の編集
  def set_top_balance(subjects_info)
    subjects_info.balance1 = subjects_info.subject1.try(&:balance).try(&:top_balance) || 0
    subjects_info.balance2 = subjects_info.subject2.try(&:balance).try(&:top_balance) || 0
  end

  # 残高部の編集
  def format_report1_carried_contents(sheet, subjects_info)
    contents_list = [
      { row: 6, col: 6, contents: subjects_info.balance1 },
      { row: 6, col: 8, contents: subjects_info.balance2 }
    ]
    ExcelService.set_cells_value(sheet, contents_list)
  end

  # 明細行のデータの取得
  def get_report1_detail_list(fiscal_year, subjects_info)
    subject_ids = subjects_info.subject_ids
    journals = Journal.
      where(fiscal_year: fiscal_year).
      with_subjects.
      where('subject_debit_id in (?) OR subject_credit_id in (?)', subject_ids, subject_ids).
      order(:journal_date)
    journals.map { |m| CashBook.from_journal(m, subjects_info) }
  end

  # 明細行の編集
  def format_report1_detail_contents(sheet, cash_book_list)
    # 明細を編集します。
    row = REPORT1_DETAIL_START_ROW_INDEX
    cash_book_list.each { |cash_book|
      contents_list = [
        { row: row, col: 1, contents: cash_book.date.strftime('%Y-%m-%d') },
        { row: row, col: 2, contents: cash_book.code },
        { row: row, col: 3, contents: cash_book.name },
        { row: row, col: 4, contents: cash_book.comment },
        { row: row, col: 5, contents: cash_book.price1 },
        { row: row, col: 6, contents: cash_book.balance1 },
        { row: row, col: 7, contents: cash_book.price2 },
        { row: row, col: 8, contents: cash_book.balance2 }
      ]
      ExcelService.set_row_fill_color(sheet, row, ODD_COLOR, REPORT1_MIN_COL_INDEX, REPORT1_MAX_COL_INDEX) if row.odd?
      ExcelService.set_cells_value(sheet, contents_list)
      row += 1
    }
  end

  # 現預金出納帳の対象勘定科目の格納クラスです。
  class Report1SubjectsInfo
    attr_accessor :subject1, :subject2, :balance1, :balance2

    def initialize(subject1, subject2)
      @subject1 = subject1
      @subject2 = subject2
    end

    def subjects
      [subject1, subject2].compact
    end

    def subject_ids
      [subject1.try(&:id), subject2.try(&:id)].compact
    end
  end
end
