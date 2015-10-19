class JournalsController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:new, :create, :edit, :update]
  before_action :set_journal, only: [:edit, :update, :destroy]
  before_action :create_tabs, only: [:new, :edit]

  def subjects_debit
    @subjects = Subject.where(fiscal_year: current_fiscal_year)
    render 'subjects', layout: false
  end

  def subjects_credit
    @subjects = Subject.where(fiscal_year: current_fiscal_year)
    render 'subjects', layout: false
  end

  def new
    @journal = Journal.new.tap { |m|
      m.fiscal_year = current_fiscal_year
      m.journal_date = session[:journal_date].to_date
    }
  end

  def edit
    Rails.logger.info "=====Journal= #{@journal}"
  end

  def create
    @journal = Journal.new(journal_params).tap { |m| m.fiscal_year = @fiscal_year }
    respond_to do |format|
      if @journal.save
        format.html { redirect_to journals_url, notice: '仕分を登録しました。' }
        format.json { render :new, status: :created, location: @journals }
      else
        format.html { render :new }
        format.json { render json: @journals.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @journal.update(journal_params)
        format.html { redirect_to fiscal_years_url, notice: '会計年度を更新しました。' }
        format.json { render :index, status: :ok, location: @journals }
      else
        format.html { render :edit }
        format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # TODO: 実装
    redirect_to :journals
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def journal_params
    params.require(:journal).permit(:journal_date, :subject_debit_id, :subject_credit_id, :price, :comment)
  end

  def create_tabs
    # TODO: タブ一覧の生成(中身はjqueryで)
  end
end
