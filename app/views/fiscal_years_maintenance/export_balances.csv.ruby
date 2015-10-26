require 'csv'

CSV.generate('', force_quotes: true) do |csv|
  cols = {
    'コード' => -> (u){ u.subject.code },
    '科目名' => -> (u){ u.subject.name },
    '期首残高' => -> (u){ u.top_balance.to_s }
  }

  csv << cols.keys
  @balances.each { |m| csv << cols.map { |_k, col| col.call(m) } }
end
