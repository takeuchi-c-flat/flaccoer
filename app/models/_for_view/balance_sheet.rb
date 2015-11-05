class BalanceSheet
  # 合計残高試算表用のクラスです。
  attr_accessor :code, :name, :before_total, :carried, :total, :last_balance

  class << self
    def from_subject_and_journal_summary(subject, top_balance, before_total, total)
      BalanceSheet.new.tap { |m|
        m.code = subject.code
        m.name = subject.name
        m.before_total = before_total
        m.carried = top_balance + before_total
        m.total = total
        m.last_balance = top_balance + before_total + total
      }
    end
  end
end
