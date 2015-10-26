require 'csv'

CSV.generate('', force_quotes: true) do |csv|
  cols = {
    '取引日' => -> (u){ u.journal_date.strftime('%Y-%m-%d') },
    '借方科目' => -> (u){ u.subject_debit.code },
    '貸方科目' => -> (u){ u.subject_credit.code },
    '金額' => -> (u){ u.price.to_s },
    '摘要' => -> (u){ u.comment }
  }

  csv << cols.keys
  @journals.each { |m| csv << cols.map { |_k, col| col.call(m) } }
end
