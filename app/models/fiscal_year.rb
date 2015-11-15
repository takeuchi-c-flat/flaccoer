class FiscalYear < ActiveRecord::Base
  self.table_name = 'fiscal_years'

  belongs_to :user
  belongs_to :account_type
  belongs_to :subject_template_type

  has_many \
    :subjects,
    -> do eager_load(:subject_type).order('subjects.code') end,
    class_name: 'Subject'
  has_many \
    :property_balances,
    -> do joins(:subject).merge(Subject.property_only).order('subjects.code') end,
    class_name: 'Balance'
  has_many \
    :debt_balances,
    -> do joins(:subject).merge(Subject.debt_only).order('subjects.code') end,
    class_name: 'Balance'
  has_many \
    :profit_badgets,
    -> do joins(:subject).merge(Subject.profit_only).order('subjects.code') end,
    class_name: 'Badget'
  has_many \
    :loss_badgets,
    -> do joins(:subject).merge(Subject.loss_only).order('subjects.code') end,
    class_name: 'Badget'

  accepts_nested_attributes_for :subjects
  accepts_nested_attributes_for :property_balances
  accepts_nested_attributes_for :debt_balances
  accepts_nested_attributes_for :profit_badgets
  accepts_nested_attributes_for :loss_badgets

  validates :title, presence: true
  validates :organization_name, presence: true
  validates :subject_template_type, presence: true
  validates :date_from, presence: true
  validates :date_to, presence: true
  validate :validate_date_span

  before_validation :set_account_type

  attr_accessor :for_copy, :base_fiscal_year_id

  def validate_date_span
    unless DateService.validate_date_order(date_from, date_to)
      errors.add(:date_to, '日付の指定が正しくありません。')
      return
    end
    unless FiscalYearService.validate_months_range(date_from, date_to)
      errors.add(:date_to, '年度の範囲が制限を超えています。')
      return
    end
  end

  def set_account_type
    if subject_template_type
      self.account_type = subject_template_type.account_type
    else
      self.account_type = nil
    end
  end

  def select_box_name
    "#{title} - #{organization_name}"
  end
end
