class ReportsBlueController < WithFiscalBaseController
  before_action :set_fiscal_year

  def index
  end

  def report1
    temp_file_name = ReportsBlueExcelService.create_report1_excel_file(@fiscal_year)
    respond_to do |format|
      format.xlsx { send_file temp_file_name, type: 'application/xlsx' }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end
end
