module DashboardService
  module_function

  # ダッシュボードのデータを生成します。(貸借勘定)
  def create_dashboard_data_debit_and_credit(fiscal_year, journal_date)
    # ダッシュボードの対象科目と期首残高を抽出
    target_subjects = Subject.
      where(fiscal_year: fiscal_year, disabled: false, dash_board: true).
      debit_and_credit_only.
      eager_load(:balance).
      order(:code)

    # 取引明細を集計
    target_subjects.map { |subject|
      debit_journals = get_debit_journals(subject, fiscal_year.date_from, journal_date)
      credit_journals = get_credit_journals(subject, fiscal_year.date_from, journal_date)

      debit_for_balance = debit_journals.map { |j| j.price_for_balance(subject) }.inject(:+) || 0
      credit_for_balance = credit_journals.map { |j| j.price_for_balance(subject) }.inject(:+) || 0
      Dashboard.new.tap { |m|
        m.code = subject.code
        m.name = subject.name
        m.top_balance = subject.balance.try(&:top_balance) || 0
        m.debit_total = debit_journals.map(&:price).inject(:+) || 0
        m.credit_total = credit_journals.map(&:price).inject(:+) || 0
        m.last_balance = m.top_balance + debit_for_balance + credit_for_balance
      }
    }
  end

  # ダッシュボードのデータを生成します。(損益勘定)
  def create_dashboard_data_profit_and_loss(fiscal_year, journal_date)
    # ダッシュボードの対象科目と年間予算を抽出
    target_subjects = Subject.
      where(fiscal_year: fiscal_year, disabled: false, dash_board: true).
      profit_and_loss_only.
      eager_load(:badget).
      order(:code)

    # 取引明細を集計
    target_subjects.map { |subject|
      debit_journals = get_debit_journals(subject, fiscal_year.date_from, journal_date)
      credit_journals = get_credit_journals(subject, fiscal_year.date_from, journal_date)

      debit_for_balance = debit_journals.map { |j| j.price_for_balance(subject) }.inject(:+) || 0
      credit_for_balance = credit_journals.map { |j| j.price_for_balance(subject) }.inject(:+) || 0
      Dashboard.new.tap { |m|
        m.code = subject.code
        m.name = subject.name
        m.total_badget = subject.badget.try(&:total_badget) || 0
        m.total_result = debit_for_balance + credit_for_balance
        m.achievement_ratio = \
          m.total_badget.zero? ? '---%' : (m.total_result * BigDecimal(100) / m.total_badget).round(1).to_s + '%'
      }
    }
  end

  def get_debit_journals(subject, date_from, date_to)
    Journal.where(subject_debit: subject).where('journal_date BETWEEN ? AND ?', date_from, date_to)
  end

  def get_credit_journals(subject, date_from, date_to)
    Journal.where(subject_credit: subject).where('journal_date BETWEEN ? AND ?', date_from, date_to)
  end
end
