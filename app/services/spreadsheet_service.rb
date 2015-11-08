require 'spreadsheet'

module SpreadsheetService
  module_function

  TEMPLATES_PATH = 'app/assets/templates/'
  TEMP_PATH = 'tmp/'

  # 一時ファイル名を生成します。
  def create_temp_file_name(file_name)
    TEMP_PATH + file_name
  end

  # WorksheetをTemplateから生成します。
  def create_workbook_from_template(template_file_name, temp_file_name, sheet_name)
    Spreadsheet.client_encoding = 'UTF-8'
    FileUtils.cp(TEMPLATES_PATH + template_file_name, temp_file_name)
    Spreadsheet.open(temp_file_name).tap { |b|
      b.worksheets[0].name = sheet_name
    }
  end

  # Workbookを書き込みます。
  def write_workbook(workbook, temp_file_name)
    workbook.write(temp_file_name)
    temp_file_name
  end

  # 行を挿入します。
  def insert_row(sheet, row)
    Rails.logger.info "===INSERT #{row}"
    if sheet.rows[row].present?
      sheet.rows[row].insert(1, sheet.rows[row].deep_dup)
    end
  end

  # 行を削除します。
  def delete_row(sheet, row)
    sheet.rows[row].delete if sheet.rows[row].present?
  end

  # 複数の指定セルに値を設定します。
  def set_cells_value(sheet, contents_list)
    contents_list.each { |hash|
      row = hash[:row]
      col = hash[:col]
      contents = hash[:contents]
      Rails.logger.info "row=#{row} col=#{col} contents=#{contents}"
      sheet.rows[row][col] = contents
    }
  end
end
