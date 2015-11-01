class Subject < ActiveRecord::Base
  self.table_name = 'subjects'

  belongs_to :fiscal_year
  belongs_to :subject_type
  has_one :balance
  has_one :badget

  scope :property_only, lambda {
    enabled_only.joins(:subject_type).merge(SubjectType.debit_only).merge(SubjectType.debit_and_credit_only)
  }
  scope :debt_only, lambda {
    enabled_only.joins(:subject_type).merge(SubjectType.credit_only).merge(SubjectType.debit_and_credit_only)
  }
  scope :profit_only, lambda {
    enabled_only.joins(:subject_type).merge(SubjectType.credit_only).merge(SubjectType.profit_and_loss_only)
  }
  scope :loss_only, lambda {
    enabled_only.joins(:subject_type).merge(SubjectType.debit_only).merge(SubjectType.profit_and_loss_only)
  }

  validates :code, uniqueness: { scope: [:fiscal_year, :code] }

  attr_accessor :usage_count

  def self.debit_and_credit_only
    enabled_only.joins(:subject_type).merge(SubjectType.debit_and_credit_only)
  end

  def self.profit_and_loss_only
    enabled_only.joins(:subject_type).merge(SubjectType.profit_and_loss_only)
  end

  def self.enabled_only
    where(disabled: false)
  end

  def get_report_locations
    [report1_location, report2_location, report3_location, report4_location, report5_location]
  end

  def mark_class_name
    return '' if subject_type.nil?
    if subject_type.debit_and_credit?
      subject_type.debit? ? 'mark-property' : 'mark-debt'
    else
      subject_type.debit? ? 'mark-loss' : 'mark-profit'
    end
  end

  def mark_label_name
    return '' if subject_type.nil?
    if subject_type.debit_and_credit?
      subject_type.debit? ? '資' : '負'
    else
      subject_type.debit? ? '支' : '収'
    end
  end

  def to_s
    name
  end

  def set_report_locations(locations)
    self.report1_location = locations[0]
    self.report2_location = locations[1]
    self.report3_location = locations[2]
    self.report4_location = locations[3]
    self.report5_location = locations[4]
  end
end
