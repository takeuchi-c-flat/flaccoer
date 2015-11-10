module DashboardService
  module_function

  # ダッシュボードのデータを生成します。(貸借勘定)
  def create_dashboard_data_debit_and_credit(fiscal_year, journal_date)
    subjects = get_target_subjects(fiscal_year, true)
    create_dashboard_data(fiscal_year, journal_date, subjects, true)
  end

  # ダッシュボードのデータを生成します。(損益勘定)
  def create_dashboard_data_profit_and_loss(fiscal_year, journal_date)
    subjects = get_target_subjects(fiscal_year, false)
    create_dashboard_data(fiscal_year, journal_date, subjects, false)
  end

  # ダッシュボードの対象勘定科目を取得します。
  def get_target_subjects(fiscal_year, is_debit_and_credit)
    subjects = Subject.where(fiscal_year: fiscal_year, disabled: false, dash_board: true)
    if is_debit_and_credit
      subjects.debit_and_credit_only.eager_load(:balance).order(:code)
    else
      subjects.profit_and_loss_only.eager_load(:badget).order(:code)
    end
  end

  # 取引明細を集計して、ダッシュボードのデータを生成します。
  def create_dashboard_data(fiscal_year, journal_date, subjects, is_debit_and_credit)
    subjects.map { |subject|
      (debit_total, credit_total, total, journal_count) = summary_subject_journals(fiscal_year, journal_date, subject)
      Dashboard.new.tap { |m|
        m.id = journal_count.zero? ? 0 : subject.id
        m.code = subject.code
        m.name = subject.name
        if is_debit_and_credit
          m.top_balance = subject.balance.try(&:top_balance) || 0
          m.debit_total = debit_total
          m.credit_total = credit_total
          m.last_balance = m.top_balance + total
        else
          m.total_badget = subject.badget.try(&:total_badget) || 0
          m.total_result = total
          m.achievement_ratio = get_achievement_ratio(m.total_badget, m.total_result)
        end
      }
    }
  end

  # 取引明細を集計します。
  def summary_subject_journals(fiscal_year, journal_date, subject)
    debit_journals = get_debit_journals(subject, fiscal_year.date_from, journal_date)
    credit_journals = get_credit_journals(subject, fiscal_year.date_from, journal_date)
    debit_for_balance = debit_journals.map { |j| j.price_for_balance(subject) }.inject(:+) || 0
    credit_for_balance = credit_journals.map { |j| j.price_for_balance(subject) }.inject(:+) || 0
    [
      debit_journals.map(&:price).inject(:+) || 0,
      credit_journals.map(&:price).inject(:+) || 0,
      debit_for_balance + credit_for_balance,
      debit_journals.length + credit_journals.length
    ]
  end

  def get_debit_journals(subject, date_from, date_to)
    Journal.where(subject_debit: subject).where('journal_date BETWEEN ? AND ?', date_from, date_to)
  end

  def get_credit_journals(subject, date_from, date_to)
    Journal.where(subject_credit: subject).where('journal_date BETWEEN ? AND ?', date_from, date_to)
  end

  def get_achievement_ratio(total_badget, total_result)
    return '---%' if total_badget.zero?
    (total_result * BigDecimal(100) / total_badget).round(1).to_s + '%'
  end
end
