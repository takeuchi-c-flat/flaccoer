class FiscalYearsMaintenanceController < BaseController
  def index
    @fiscal_year = FiscalYear.where(id: params[:id]).first
    unless @fiscal_year
      redirect_to :fiscal_years
      return
    end

    @journals_count = Journal.where(fiscal_year: @fiscal_year).length
    @balances_count = Balance.where(fiscal_year: @fiscal_year).length
    @badgets_count = Badget.where(fiscal_year: @fiscal_year).length
  end

  def trunc_journals
    # TODO: Journalの削除の実装(実装は後で、まずは残高とかの入力を先行)
    Rails.logger.info '======Journalの削除が呼ばれています。======'
    redirect_to :fiscal_year_maintenance
  end

  def trunc_balances
    # TODO: Balanceの削除の実装(実装は後で、まずは残高とかの入力を先行)
    Rails.logger.info '======Balanceの削除が呼ばれています。======'
    redirect_to :fiscal_year_maintenance
  end

  def trunc_badgets
    # TODO: Badgetの削除の実装(実装は後で、まずは残高とかの入力を先行)
    Rails.logger.info '======Badgetの削除が呼ばれています。======'
    redirect_to :fiscal_year_maintenance
  end
end
