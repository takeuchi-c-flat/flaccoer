module LedgerService
  module_function

  # 元帳が出力可能な勘定科目のリストを取得します。
  def get_subject_list(fiscal_year)
    journals = Journal.where(fiscal_year: fiscal_year).eager_load(:subject_debit).eager_load(:subject_credit)
    (journals.map(&:subject_debit) + journals.map(&:subject_credit)).
      group_by { |model| model }.
      map { |model, _list| model }.
      sort_by { |model| model.code }
  end

  # 総勘定元帳の繰越残高を取得します。
  def get_ledger_carried_balance(fiscal_year, subject, date_from)
    top_balance = Balance.find_by(fiscal_year: fiscal_year, subject: subject).try(&:top_balance) || 0
    journals = Journal.
      where(fiscal_year: fiscal_year).
      with_subjects.
      where('journal_date < ?', date_from).
      where('(subject_debit_id = ? OR subject_credit_id = ?)', subject.id, subject.id)
    top_balance + (journals.length > 0 ? journals.map { |m| m.price_for_balance(subject) }.inject(:+) : 0)
  end

  # 総勘定元帳のリストを取得します。
  def get_ledger_list(fiscal_year, subject, date_from, date_to, carried_balance)
    journals = Journal.
      where(fiscal_year: fiscal_year).
      with_subjects.
      where('journal_date BETWEEN ? AND ?', date_from, date_to).
      where('(subject_debit_id = ? OR subject_credit_id = ?)', subject.id, subject.id).
      order([:journal_date, :id])
    balance = carried_balance
    journals.each { |m|
      match_debit = m.subject_debit == subject
      m.ledger_subject = match_debit ? m.subject_credit : m.subject_debit
      m.price_debit = match_debit ? m.price : 0
      m.price_credit = match_debit ? 0 : m.price
      m.balance = balance + m.price_for_balance(subject)
      balance = m.balance
    }
  end
end
