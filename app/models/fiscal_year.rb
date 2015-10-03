class FiscalYear < ActiveRecord::Base
  self.table_name = 'fiscal_years'

  belongs_to :user
  belongs_to :account_type
  belongs_to :subject_template_type

  validates :title, presence: true
  validates :organization_name, presence: true
  validates :subject_template_type, presence: true
  validates :date_from, presence: true
  validates :date_to, presence: true
  validate :validate_date_span

  before_validation :set_account_type

  def validate_date_span
    unless DateService.validate_date_order(date_from, date_to)
      errors.add(:date_to, '日付の指定が正しくありません。')
      return
    end
    unless FiscalYearService.validate_months_range(date_from, date_to)
      errors.add(:date_to, '年度の範囲が制限を超えています。')
      return
    end
    # TODO: 更新の場合に、取引明細との関連のチェックを追加
  end

  def set_account_type
    if subject_template_type
      self.account_type = subject_template_type.account_type
    else
      self.account_type = nil
    end
  end
end
