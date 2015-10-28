class Journal < ActiveRecord::Base
  self.table_name = 'journals'

  belongs_to :fiscal_year
  belongs_to :subject_debit, class_name: 'Subject', foreign_key: 'subject_debit_id'
  belongs_to :subject_credit, class_name: 'Subject', foreign_key: 'subject_credit_id'

  validates :journal_date, presence: true
  validates :subject_debit, presence: true
  validates :subject_credit, presence: true
  validate :validate_subject
  validate :validate_journal_date

  def validate_subject
    if subject_debit == subject_credit
      errors.add(:subject_debit, ' 貸借に同じ科目が指定されています。')
      return
    end
  end

  def validate_journal_date
    unless FiscalYearService.validate_journal_date(fiscal_year, journal_date)
      errors.add(:journal_date, ' 日付が年度の範囲外です。')
      return
    end
  end

  # 特定の科目の残高に対する増減値を返す
  def price_for_balance(subject)
    return 0 if subject_debit_id != subject.id && subject_credit_id != subject.id

    type = subject.subject_type
    plus_minus = (type.debit? ? 1 : -1) * (subject_debit_id == subject.id ? 1 : -1)
    price * plus_minus
  end
end
