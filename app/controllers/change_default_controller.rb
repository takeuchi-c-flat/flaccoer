class ChangeDefaultController < WithFiscalBaseController
  def edit
    @fiscal_years = FiscalYearService.accessible_fiscal_years(current_user)
    @change_default_form = ChangeDefaultForm.new.tap { |form|
      form.fiscal_year_id = current_fiscal_year.id
      form.journal_date = session[:journal_date].present? ? session[:journal_date].to_date : Date.today
    }
  end

  def change
    set_session_by_form(change_default_form_params)
    redirect_to :root
  end

  private

  def set_session_by_form(form)
    fiscal_year = FiscalYear.find_by(id: form[:fiscal_year_id])
    session[:fiscal_year_id] = fiscal_year.nil? ? nil : fiscal_year.id.to_s
    session[:journal_date] = FiscalYearService.adjust_journal_date(form[:journal_date].to_date, fiscal_year).to_s
  end

  def change_default_form_params
    params.require(:change_default_form).permit(:fiscal_year_id, :journal_date)
  end
end
