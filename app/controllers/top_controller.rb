class TopController < BaseController
  # TOP画面は、事前認証はSKIPします。
  skip_before_action :authorize

  def index
    if current_user
      render action: 'index'
    else
      redirect_to :login
    end
  end
end
