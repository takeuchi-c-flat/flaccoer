module AuthenticationService
  module_function

  # User を e-mailとパスワードで認証します。成功時はUserを返します。
  def authenticate(email, password)
    user = User.find_by(email_for_index: email.downcase)
    return nil if user.nil? || BCrypt::Password.new(user.hashed_password) != password
    user
  end
end
