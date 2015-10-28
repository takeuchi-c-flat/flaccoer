class FiscalYearsMaintenanceController < BaseController
  before_action :set_fiscal_year
  before_action :set_upload_file, only: [:import_journals, :import_subjects, :import_balances, :import_badgets]

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
          export_path: export_journals_path(@fiscal_year, format: :csv),
          import_url: import_journals_url,
          delete_path: trunc_journals_path(@fiscal_year)
        },
        {
          title: '勘定科目',
          count: subjects_count,
          any_records: !subjects_count.zero?,
          can_delete: !subjects_count.zero? && journals_count.zero? && balances_count.zero? && badgets_count.zero?,
          export_path: export_subjects_path(@fiscal_year, format: :csv),
          import_url: import_subjects_url,
          delete_path: trunc_subjects_path(@fiscal_year)
        },
        {
          title: '期首残高',
          count: balances_count,
          any_records: !balances_count.zero?,
          can_delete: !balances_count.zero?,
          export_path: export_balances_path(@fiscal_year, format: :csv),
          import_url: import_balances_url,
          delete_path: trunc_balances_path(@fiscal_year)
        },
        {
          title: '年間予算',
          count: badgets_count,
          any_records: !badgets_count.zero?,
          can_delete: !badgets_count.zero?,
          export_path: export_badgets_path(@fiscal_year, format: :csv),
          import_url: import_badgets_url,
          delete_path: trunc_badgets_path(@fiscal_year)
        }
      ]
    @upload_file_form = UploadFileForm.new
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

  def import_journals
    do_import(:journals)
  end

  def import_subject
    do_import(:subjects)
    redirect_to :fiscal_year_maintenance
  end

  def import_balances
    do_import(:balances)
  end

  def import_badgets
    do_import(:badgets)
  end

  def upload_params
    return nil if params[:upload_file_form].nil?
    params.require(:upload_file_form).permit(:upload_file)
  end

  private

  def set_fiscal_year
    @fiscal_year = FiscalYear.where(id: params[:id]).first
    redirect_to :fiscal_years unless @fiscal_year
  end

  def set_upload_file
    return if upload_params.nil?
    upload_file = upload_params[:upload_file]
    @upload_file_content = upload_file.present? ? upload_file.read : nil
  end

  def do_import(type)
    if @upload_file_content.present?
      (result, infos) = CsvImportService.import_csv_data(@fiscal_year, type, @upload_file_content)
      notice = infos if result
      alert = infos unless result
    end
    respond_to do |format|
      format.html { redirect_to fiscal_year_maintenance_url, notice: notice, alert: alert }
    end
  end
end
