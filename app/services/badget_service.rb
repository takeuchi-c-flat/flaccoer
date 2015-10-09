module BadgetService
  module_function

  # 会計年度に対して、存在していない通期予算のレコードを先に作り込みます.
  # 無効になっている科目があれば、逆に削除します.
  def pre_create_badgets(fiscal_year)
    # 無効になっている分があれば削除
    error_badgets = Badget.where(fiscal_year: fiscal_year).
      eager_load(:subject).
      select { |m| m.subject.disabled? }
    error_badgets.each(&:destroy!)

    # 足りない分を追加
    subjects = Subject.where(fiscal_year: fiscal_year).
      profit_and_loss_only.
      eager_load(:badget)
    created = 0
    subjects.
      reject { |m| m.badget.present? }.
      each { |m|
      created += 1
      Badget.create(fiscal_year: fiscal_year, subject: m, total_badget: 0)
    }
    created
  end
end
