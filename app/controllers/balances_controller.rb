class BalancesController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:edit, :update]

  def edit
    # 存在しないレコードは、先に作ってしまう。
    BalanceService.pre_create_balances(@fiscal_year)
  end

  def update
    respond_to do |format|
      @fiscal_year.update(fiscal_year_params)
      SubjectService.cleanup_subjects(@fiscal_year)
      format.html { redirect_to balances_url, notice: '期首残高を更新しました。(バックアップをしましょう)' }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def fiscal_year_params
    params.require(:fiscal_year).permit(
      :id,
      subjects_attributes: [:id],
      property_balances_attributes: [:id, :subject_id, :top_balance],
      debt_balances_attributes: [:id, :subject_id, :top_balance])
  end
end
