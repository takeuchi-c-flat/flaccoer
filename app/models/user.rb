class User < ActiveRecord::Base
  self.table_name = 'users'

  attr_accessor :password, :new_password1, :new_password2

  validates :email, presence: true, uniqueness: true
  validates :password, presence: { if: :new_record? }
  validates :name, presence: true

  before_validation do
    self.email_for_index = email.downcase if email
    self.hashed_password = BCrypt::Password.create(password) if password.is_a?(String)
  end

  def to_s
    name
  end
end
