class FiscalYear < ActiveRecord::Base
  self.table_name = 'fiscal_years'

  belongs_to :user
  belongs_to :account_type
  belongs_to :subject_template_type

  validates :title, presence: true
  validates :subject_template_type, presence: true
  validates :date_from, presence: true
  validates :date_to, presence: true

  before_validation :set_account_type

  def set_account_type
    if subject_template_type
      self.account_type = subject_template_type.account_type
    else
      self.account_type = nil
    end
  end
end
