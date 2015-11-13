class LocationsController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:edit_all, :update_all]

  def edit_all
  end

  def update_all
    respond_to do |format|
      @fiscal_year.update(fiscal_year_params)
      format.html { redirect_to locations_url, notice: '勘定科目の帳票位置を更新しました。(バックアップをしましょう)' }
      format.json { render :index, location: @locations }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def fiscal_year_params
    params.require(:fiscal_year).permit(
      :id,
      subjects_attributes: [
        :id, :code, :name,
        :report1_location, :report2_location, :report3_location, :report4_location, :report5_location,
        :disabled, :dash_board])
  end
end
