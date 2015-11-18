class WatchUser < ActiveRecord::Base
  self.table_name = 'watch_users'

  belongs_to :fiscal_year
  belongs_to :user

  validate :validate_user
  validates :user, uniqueness: { scope: [:fiscal_year, :user] }

  attr_accessor :user_email

  before_validation do
    if new_record? && user_email.present?
      self.user = User.find_by(email_for_index: user_email.downcase)
    end
  end

  def validate_user
    errors.add(:user_email, ' 指定したe-mailのユーザが見つかりません。') if user.nil?
    errors.add(:user_email, ' 指定したe-mailは、あなたのアカウントです。') if user.present? && fiscal_year.user == user
  end
end
