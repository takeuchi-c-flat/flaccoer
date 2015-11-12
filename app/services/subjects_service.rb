module SubjectsService
  module_function

  # 勘定科目の取引明細を取得して、削除が可能かをチェックします。
  def subject_can_delete?(fiscal_year, subject)
    Journal.where(fiscal_year: fiscal_year, subject_debit: subject).empty? &&
      Journal.where(fiscal_year: fiscal_year, subject_credit: subject).empty?
  end

  # 勘定科目に関するDataBaseのCleanupを行ないます。
  def cleanup_subjects(fiscal_year)
    balances = Balance.where(fiscal_year: fiscal_year)
    badgets = Badget.where(fiscal_year: fiscal_year)
    # 無効に設定している勘定科目の期首残高と年間予算を削除します。
    balances.eager_load(:subject).select { |m| m.subject.disabled }.each { |m| m.destroy! }
    badgets.eager_load(:subject).select { |m| m.subject.disabled }.each { |m| m.destroy! }

    # 金額がゼロの期首残高と年間予算を削除します。
    balances.where(top_balance: 0).each { |m| m.destroy! }
    badgets.where(total_badget: 0).each { |m| m.destroy! }
  end

  # 会計年度分の勘定科目のリストを取得します。
  def get_subject_list(fiscal_year, with_sort = true)
    list = Subject.where(fiscal_year: fiscal_year, disabled: false).eager_load(:subject_type)
    return list unless with_sort
    list.sort_by { |m| m.code }
  end

  # 使用ランキング順の借方・貸方勘定科目のListを生成します。
  def create_subject_list_with_usage_ranking(fiscal_year, for_debit)
    rankings = get_subject_usage_ranking(fiscal_year, for_debit)
    subjects = get_subject_list(fiscal_year, false).each { |subject|
      ranking = rankings.find { |m| m.id == subject.id }
      subject.usage_count = ranking.nil? ? 0 : ranking.usage_count
    }
    subjects.sort_by { |subject| "#{(1000 - subject.usage_count).to_s.rjust(4, '0')}|#{subject.code}" }.to_a
  end

  # 使用ランキング付きの借方勘定科目のListを取得します。
  def get_subject_usage_ranking(fiscal_year, for_debit)
    subject_symbol = (for_debit ? 'subject_debit' : 'subject_credit').to_sym
    all_journals = Journal.where(fiscal_year: fiscal_year).eager_load(subject_symbol)
    all_journals.
      group_by { |journal| for_debit ? journal.subject_debit : journal.subject_credit }.
      map { |subject, journals| subject.tap { |s| s.usage_count = journals.length } }.
      reject { |subject| subject.disabled }
  end
end
