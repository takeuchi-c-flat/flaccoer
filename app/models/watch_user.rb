class WatchUser < ActiveRecord::Base
  self.table_name = 'watch_users'

  belongs_to :fiscal_year
  belongs_to :user

  validate :validate_user
  validates :user, uniqueness: { scope: [:fiscal_year, :user] }

  attr_accessor :user_email

  def validate_user
    errors.add(:user_email, ' 指定したe-mailのユーザが見つかりません。') if user.nil?
  end
end
