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
  validates :price, presence: true

  attr_accessor :ledger_subject, :price_debit, :price_credit, :balance

  def self.with_subjects
    eager_load(subject_debit: [:subject_type]).eager_load(subject_credit: [:subject_type])
  end

  def self.select_by_subject(subject)
    where('subject_debit_id = ? OR subject_credit_id = ?', subject.id, subject.id)
  end

  def validate_subject
    errors.add(:subject_debit, ' 貸借に同じ科目が指定されています。') if subject_debit == subject_credit
  end

  def validate_journal_date
    unless FiscalYearService.validate_journal_date(fiscal_year, journal_date)
      errors.add(:journal_date, ' 年度の範囲外です。')
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
