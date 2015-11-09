class BalanceSheetController < WithFiscalBaseController
  before_action :set_fiscal_year

  def index
    @balance_sheet_form = BalanceSheetForm.new.tap { |f|
      f.date_from = @fiscal_year.date_from
      f.date_to = @fiscal_year.date_to
    }
  end

  def list
    params = balance_sheet_params
    date_from = Date.strptime(params[:date_from], '%Y/%m/%d')
    date_to = Date.strptime(params[:date_to], '%Y/%m/%d')

    @balance_sheet_list = [
      {
        title: '貸借対照表',
        list: BalanceSheetService.get_balance_sheet_list_debit_and_credit(@fiscal_year, date_from, date_to)
      },
      {
        title: '損益計算書',
        list: BalanceSheetService.get_balance_sheet_list_profit_and_loss(@fiscal_year, date_from, date_to)
      }
    ]
    render 'list', layout: false
  end

  def excel_bs
    response_excel_file(true)
  end

  def excel_pl
    response_excel_file(false)
  end

  private

  def response_excel_file(is_balance_sheet)
    date_from = Date.strptime(params[:date_from], '%Y%m%d')
    date_to = Date.strptime(params[:date_to], '%Y%m%d')
    temp_file_name = BalanceSheetExcelService.create_excel_file(@fiscal_year, date_from, date_to, is_balance_sheet)
    respond_to do |format|
      format.xlsx { send_file temp_file_name, type: 'application/xlsx' }
    end
  end

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def balance_sheet_params
    params.require(:balance_sheet_form).permit(:date_from, :date_to)
  end
end
