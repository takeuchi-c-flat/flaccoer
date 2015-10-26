class FiscalYearsMaintenanceController < BaseController
  before_action :set_fiscal_year

  # rubocop:disable Metrics/AbcSize
  def index
    journals_count = Journal.where(fiscal_year: @fiscal_year).length
    subjects_count = Subject.where(fiscal_year: @fiscal_year).length
    balances_count = Balance.where(fiscal_year: @fiscal_year).length
    badgets_count = Badget.where(fiscal_year: @fiscal_year).length
    @maintenance_items =
      [
        {
          title: '取引明細',
          count: journals_count,
          any_records: !journals_count.zero?,
          can_delete: !journals_count.zero?,
          delete_path: trunc_journals_path(@fiscal_year),
          export_path: export_journals_path(@fiscal_year, format: :csv)
        },
        {
          title: '勘定科目',
          count: subjects_count,
          any_records: !subjects_count.zero?,
          can_delete: !subjects_count.zero? && journals_count.zero? && balances_count.zero? && badgets_count.zero?,
          delete_path: trunc_subjects_path(@fiscal_year),
          export_path: export_subjects_path(@fiscal_year, format: :csv)
        },
        {
          title: '期首残高',
          count: balances_count,
          any_records: !balances_count.zero?,
          can_delete: !balances_count.zero?,
          delete_path: trunc_balances_path(@fiscal_year),
          export_path: export_balances_path(@fiscal_year, format: :csv)
        },
        {
          title: '年間予算',
          count: badgets_count,
          any_records: !badgets_count.zero?,
          can_delete: !badgets_count.zero?,
          delete_path: trunc_badgets_path(@fiscal_year),
          export_path: export_badgets_path(@fiscal_year, format: :csv)
        }
      ]
  end
  # rubocop:enable Metrics/AbcSize

  def trunc_journals
    Journal.where(fiscal_year: @fiscal_year).each { |m| m.destroy! }
    redirect_to :fiscal_year_maintenance
  end

  def trunc_subjects
    Subject.where(fiscal_year: @fiscal_year).each { |m| m.destroy! }
    redirect_to :fiscal_year_maintenance
  end

  def trunc_balances
    Balance.where(fiscal_year: @fiscal_year).each { |m| m.destroy! }
    redirect_to :fiscal_year_maintenance
  end

  def trunc_badgets
    Badget.where(fiscal_year: @fiscal_year).each { |m| m.destroy! }
    redirect_to :fiscal_year_maintenance
  end

  def export_journals
    @journals = Journal.where(fiscal_year: @fiscal_year).order([:journal_date, :id])
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "journals-#{Date.today}.csv", type: :csv
      end
    end
  end

  def export_subjects
    @subjects = Subject.where(fiscal_year: @fiscal_year).order(:code)
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "subjects-#{Date.today}.csv", type: :csv
      end
    end
  end

  def export_balances
    @balances = Balance.where(fiscal_year: @fiscal_year).where('top_balance != 0').sort_by { |m| m.subject.code }
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "balances-#{Date.today}.csv", type: :csv
      end
    end
  end

  def export_badgets
    @badgets = Badget.where(fiscal_year: @fiscal_year).where('total_badget != 0').sort_by { |m| m.subject.code }
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "badgets-#{Date.today}.csv", type: :csv
      end
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = FiscalYear.where(id: params[:id]).first
    redirect_to :fiscal_years unless @fiscal_year
  end
end
