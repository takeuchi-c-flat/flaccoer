class SecuritiesController < BaseController
  def edit
    @user = current_user
  end

  def update
    @user = User.find_by(id: current_user.id)
    params = user_params

    unless AuthenticationService.authenticate(@user.email, params[:password])
      flash.now.alert = '現在のパスワードが一致しません。'
      render action: 'edit'
      return
    end

    if params[:new_password1] != params[:new_password2]
      flash.now.alert = '確認用パスワードが一致しません。'
      render action: 'edit'
      return
    end

    @user.password = params[:new_password1]
    if @user.save!
      session.delete(:user_id)
      flash.notice = 'パスワードを変更しました。再度ログインしてください。'
      redirect_to :login
    else
      render action: 'edit'
    end
  end

  def user_params
    params.require(:user).permit(:password, :new_password1, :new_password2)
  end
end
