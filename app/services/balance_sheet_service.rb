module BalanceSheetService
  module_function

  # 合計残高試算表のリストを取得します。(貸借対象表)
  def get_balance_sheet_list_debit_and_credit(fiscal_year, date_from, date_to)
    get_balance_sheet_list(fiscal_year, date_from, date_to, true)
  end

  # 合計残高試算表のリストを取得します。(損益計算書)
  def get_balance_sheet_list_profit_and_loss(fiscal_year, date_from, date_to)
    get_balance_sheet_list(fiscal_year, date_from, date_to, false)
  end

  # 合計残高試算表のリストを取得します。
  def get_balance_sheet_list(fiscal_year, date_from, date_to, is_debit_and_credit)
    # 資産・負債の科目をそれぞれ取得します。
    debit_list = get_subject_summary_list(fiscal_year, date_from, date_to, true, is_debit_and_credit)
    credit_list = get_subject_summary_list(fiscal_year, date_from, date_to, false, is_debit_and_credit)

    # 余剰金のItemを生成します。
    before_total = (debit_list.map(&:before_total).inject(:+) || 0) - (credit_list.map(&:before_total).inject(:+) || 0)
    journal_total = (debit_list.map(&:total).inject(:+) || 0) - (credit_list.map(&:total).inject(:+) || 0)
    surplus = create_surplus_item(
      before_total * (is_debit_and_credit ? 1 : -1),
      journal_total * (is_debit_and_credit ? 1 : -1))

    # 貸借のListをMergeして全て一対の形のListにします。
    merge_models(debit_list, credit_list, surplus, !is_debit_and_credit)
  end

  # 特定の勘定区分の科目の発生・残高一覧をBalanceSheet ModelのListで取得します。
  def get_subject_summary_list(fiscal_year, date_from, date_to, is_credit, is_debit_and_credit)
    subjects = Subject.eager_load(:subject_type).
      where(fiscal_year: fiscal_year, disabled: false).
      where('subject_types.debit = ? AND subject_types.debit_and_credit = ?', is_credit, is_debit_and_credit).
      to_a
    all_balances = Balance.eager_load(:subject).where(subject: subjects)
    subjects.
      map { |subject|
        top_balance = all_balances.find { |m| m.subject == subject }.try(&:top_balance) || 0
        (before_total, journal_total) = get_totals_by_subject(fiscal_year, subject, date_from, date_to)
        BalanceSheet.from_subject_and_journal_summary(subject, top_balance, before_total, journal_total)
      }.
      sort_by { |m| m.code }
  end

  # 指定した勘定科目の指定期間内の取引金額を集計して取得します。
  # @return [[Integer,Integer,Integer,Integer,Integer]] 指定期間までの取引合計・指定期間内の取引合計
  def get_totals_by_subject(fiscal_year, subject, date_from, date_to)
    journals = Journal.
      where(fiscal_year: fiscal_year).
      with_subjects.
      where('journal_date BETWEEN ? AND ?', fiscal_year.date_from, date_to).
      where('(subject_debit_id = ? OR subject_credit_id = ?)', subject.id, subject.id)

    [
      journals.select { |m| m.journal_date < date_from }.map { |m| m.price_for_balance(subject) }.inject(:+) || 0,
      journals.reject { |m| m.journal_date < date_from }.map { |m| m.price_for_balance(subject) }.inject(:+) || 0
    ]
  end

  # 余剰金のItemを生成します。
  def create_surplus_item(carried, total)
    BalanceSheet.new.tap { |m|
      m.name = '＊＊剰余金＊＊'
      m.carried = carried
      m.total = total
      m.last_balance = carried + total
    }
  end

  # 貸借のBalanceSheet(Model)をMergeします。(全ての行を一対の形で生成します)
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def merge_models(debit_list, credit_list, last_item, last_is_debit)
    debit_length = debit_list.length + (last_is_debit ? 1 : 0)
    credit_length = credit_list.length + (last_is_debit ? 0 : 1)
    max_index = [debit_length, credit_length].max - 1
    (0..max_index).map { |index|
      debit = (last_is_debit && index == max_index) ? last_item : (debit_list[index] || BalanceSheet.new)
      credit = (!last_is_debit && index == max_index) ? last_item : (credit_list[index] || BalanceSheet.new)
      [debit, credit]
    }
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
