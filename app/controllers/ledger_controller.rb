class LedgerController < WithFiscalBaseController
  before_action :set_fiscal_year

  def index
    @ledger_form = LedgerForm.new.tap { |f|
      f.date_from = @fiscal_year.date_from
      f.date_to = @fiscal_year.date_to
    }
    @subjects = LedgerService.get_subject_list(@fiscal_year)
  end

  def list
    subject = Subject.find(ledger_params[:subject_id])
    date_from = ledger_params[:date_from]
    date_to = ledger_params[:date_to]
    @carried_balance = LedgerService.get_ledger_carried_balance(@fiscal_year, subject, date_from)
    @ledger_list = LedgerService.get_ledger_list(@fiscal_year, subject, date_from, date_to, @carried_balance)
    render 'list', layout: false
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
    @journal_date = session[:journal_date].to_date
  end

  def ledger_params
    params.require(:ledger_form).permit(:subject_id, :date_from, :date_to)
  end
end
