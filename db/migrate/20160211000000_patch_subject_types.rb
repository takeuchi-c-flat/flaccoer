class PatchSubjectTypes < ActiveRecord::Migration
  def change

    # 出納帳会計の収入・支出の科目の貸借が間違っているので修正する。
    account_type = AccountType.where(code: 'SINGLE')

    profit = SubjectType.find_by(account_type: account_type, name: '収入の部')
    profit.debit = false
    profit.credit = true
    profit.save()

    loss = SubjectType.find_by(account_type: account_type, name: '支出の部')
    loss.debit = true
    loss.credit = false
    loss.save()
  end
end
