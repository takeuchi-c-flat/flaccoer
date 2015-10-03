class FiscalYearsController < BaseController
  before_action :set_fiscal_year, only: [:edit, :update, :destroy]

  def index
    @fiscal_years = FiscalYear.where(user: current_user)
  end

  def new
    @fiscal_year = FiscalYear.new.tap { |m| m.user = current_user }
  end

  def edit
  end

  def create
    @fiscal_year = FiscalYear.new(fiscal_year_params).tap { |m| m.user = current_user }

    # TODO: 科目の生成も追加
    respond_to do |format|
      if @fiscal_year.save
        format.html { redirect_to fiscal_years_url, notice: '会計年度を登録しました。' }
        format.json { render :index, status: :created, location: @fiscal_years }
      else
        format.html { render :new }
        format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @fiscal_year.update(fiscal_year_params)
        format.html { redirect_to fiscal_years_url, notice: '会計年度を更新しました。' }
        format.json { render :index, status: :ok, location: @fiscal_years }
      else
        format.html { render :edit }
        format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fiscal_year.destroy
    # TODO: 取引明細の存在チェックを追加
    # TODO: 科目の削除も追加
    respond_to do |format|
      format.html { redirect_to fiscal_years_url, notice: '会計年度を削除しました。' }
      format.json { head :no_content }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = FiscalYear.find(params[:id])
  end

  def fiscal_year_params
    params.
      require(:fiscal_year).
      permit(:user_id, :account_type_id, :subject_template_type_id, :title, :date_from, :date_to, :locked)
  end
end
