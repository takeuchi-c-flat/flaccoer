class JournalsController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:list, :new, :copy, :create, :edit, :update]
  before_action :set_journal, only: [:copy, :edit, :update, :destroy]
  before_action :create_tabs, only: [:new, :copy, :create, :edit, :update]

  def subjects_debit
    @subjects = Subject.where(fiscal_year: current_fiscal_year)
    @td_class_name = 'select-subject-debit'
    render 'subjects', layout: false
  end

  def subjects_credit
    @subjects = Subject.where(fiscal_year: current_fiscal_year)
    @td_class_name = 'select-subject-credit'
    render 'subjects', layout: false
  end

  def list
    tab_name = params[:id]
    @journals = JournalsService.journal_list_from_tab_name(tab_name, current_fiscal_year)
    render 'list', layout: false
  end

  def new
    @is_copy = false
    @journal = Journal.new.tap { |m|
      m.fiscal_year = current_fiscal_year
      m.journal_date = session[:journal_date].to_date
    }
  end

  def copy
    @is_copy = true
    @journal = @journal.dup.tap { |m|
      m.journal_date = session[:journal_date].to_date
    }
  end

  def create
    @journal = Journal.new(journal_params).tap { |m| m.fiscal_year = @fiscal_year }
    respond_to do |format|
      if @journal.save
        format.html { redirect_to journals_url, notice: '取引明細を登録しました。' }
        format.json { render :new, status: :created, location: @journals }
      else
        format.html { render :new }
        format.json { render json: @journals.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @journal.update(journal_params)
        format.html { redirect_to journals_url, notice: '会計年度を更新しました。' }
        format.json { render :index, status: :ok, location: @journals }
      else
        format.html { render :edit }
        format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @journal.destroy
    respond_to do |format|
      format.html { redirect_to journals_url, notice: '取引明細を削除しました。' }
      format.json { head :no_content }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
    @journal_date = session[:journal_date].to_date
  end

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def journal_params
    params.require(:journal).permit(:journal_date, :subject_debit_id, :subject_credit_id, :price, :comment)
  end

  def create_tabs
    @journal_months = JournalsService.create_journal_months(@fiscal_year, @journal_date)
  end
end
