require 'csv'

CSV.generate('', force_quotes: true) do |csv|
  cols = {
    'コード' => -> (u){ u.subject.code },
    '科目名' => -> (u){ u.subject.name },
    '年間予算' => -> (u){ u.total_badget.to_s }
  }

  csv << cols.keys
  @badgets.each { |m| csv << cols.map { |_k, col| col.call(m) } }
end
