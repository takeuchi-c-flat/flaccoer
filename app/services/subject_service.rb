module SubjectService
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
end
