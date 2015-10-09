module BalanceService
  module_function

  # 会計年度に対して、存在していない期首残高のレコードを先に作り込みます.
  # 無効になっている科目があれば、逆に削除します.
  def pre_create_balances(fiscal_year)
    # 無効になっている分があれば削除
    error_balances = Balance.where(fiscal_year: fiscal_year).
      eager_load(:subject).
      select { |m| m.subject.disabled? }
    error_balances.each(&:destroy!)

    # 足りない分を追加
    subjects = Subject.where(fiscal_year: fiscal_year).
      debit_and_credit_only.
      eager_load(:balance)
    created = 0
    subjects.
      reject { |m| m.balance.present? }.
      each { |m|
        created += 1
        Balance.create(fiscal_year: fiscal_year, subject: m, top_balance: 0)
      }
    created
  end
end
