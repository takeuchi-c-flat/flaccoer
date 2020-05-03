require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

module ExcelService
  module_function

  TEMPLATES_PATH = 'app/assets/templates/'
  TEMP_PATH = 'tmp/'

  # 一時ファイル名を生成します。
  def create_temp_file_name(file_name)
    TEMP_PATH + file_name
  end

  # WorksheetをTemplateから生成します。
  def create_workbook_from_template(template_file_name, temp_file_name, sheet_name)
    FileUtils.cp(TEMPLATES_PATH + template_file_name, temp_file_name)
    RubyXL::Parser.parse(temp_file_name).tap { |b|
      b.worksheets[0].sheet_name = sheet_name
    }
  end

  # Workbookから先頭のWorksheetを取得します。
  def get_first_sheet(workbook)
    workbook.worksheets[0]
  end

  # Workbookを書き込みます。
  def write_workbook(workbook)
    workbook.write
  end

  # 指定行の背景色を設定します。
  def set_row_fill_color(sheet, row, color, min_col_index, max_col_index)
    (min_col_index..max_col_index).each { |col|
      sheet.add_cell(row, col, '') if sheet[row].nil? || sheet[row][col].nil?
      sheet[row][col].change_fill(color)
    }
  end

  # 複数の指定セルに値を設定します。
  def set_cells_value(sheet, contents_list)
    contents_list.each { |hash|
      row = hash[:row]
      col = hash[:col]
      contents = hash[:contents]
      if sheet[row].nil? || sheet[row][col].nil?
        sheet.add_cell(row, col, contents)
      else
        sheet[row][col].change_contents(contents)
      end
    }
  end
end
