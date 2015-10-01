class SessionsController < BaseController
  # ログイン用の画面なので、事前認証はSKIPします。
  skip_before_action :authorize

  def new
    if current_user
      destroy
    else
      @user = User.new
      render action: 'new'
    end
  end

  def create
    @user = User.new(params[:login_form])
    @user.assign_attributes(user_params)
    if @user.email.present?
      user = AuthenticationService.authenticate(@user.email, @user.password)
    end
    if user && user.suspended?
      flash.now.alert = 'アカウントは停止されています。'
      render action: 'new'
    elsif user
      session[:user_id] = user.id
      session[:last_access_time] = Time.current
      flash.notice = 'ログインしました。'
      redirect_to :root
    else
      flash.now.alert = 'メールアドレスまたはパスワードが正しくありません。'
      render action: 'new'
    end
  end

  def destroy
    session.delete(:user_id)
    flash.notice = 'ログアウトしました。'
    redirect_to :login
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
