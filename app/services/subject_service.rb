module SubjectService
  module_function

  # 勘定科目の取引明細を取得して、削除が可能かをチェックします。
  def subject_can_delete?(fiscal_year, subject)
    Journal.where(fiscal_year: fiscal_year, subject_debit: subject).empty? &&
      Journal.where(fiscal_year: fiscal_year, subject_credit: subject).empty?
  end
end
