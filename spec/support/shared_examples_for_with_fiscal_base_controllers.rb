shared_examples 'a protected with fiscal base controller for edit with id' do
  describe '#edit' do
    let(:params_hash) { attributes_for(:user) }
    let(:current_user) { create(:user) }

    before do
      session[:user_id] = current_user.id
      session[:last_access_time] = Time.current
    end

    example '会計年度未選択時は、TOPにリダイレクト' do
      get :edit, id: 0
      expect(response).to redirect_to(root_url)
    end

    after do
      session.delete(:user_id)
      session.delete(:last_access_time)
    end
  end
end

shared_examples 'a protected with fiscal base controller for new' do
  describe '#new' do
    let(:params_hash) { attributes_for(:user) }
    let(:current_user) { create(:user) }

    before do
      session[:user_id] = current_user.id
      session[:last_access_time] = Time.current
    end

    example '会計年度未選択時は、TOPにリダイレクト' do
      get :new
      expect(response).to redirect_to(root_url)
    end

    after do
      session.delete(:user_id)
      session.delete(:last_access_time)
    end
  end
end

shared_examples 'a protected with fiscal base controller for index' do
  describe '#index' do
    let(:params_hash) { attributes_for(:user) }
    let(:current_user) { create(:user) }

    before do
      session[:user_id] = current_user.id
      session[:last_access_time] = Time.current
    end

    example '会計年度未選択時は、TOPにリダイレクト' do
      get :index
      expect(response).to redirect_to(root_url)
    end

    after do
      session.delete(:user_id)
      session.delete(:last_access_time)
    end
  end
end

shared_examples 'a protected with fiscal base controller for edit_all' do
  describe '#index' do
    let(:params_hash) { attributes_for(:user) }
    let(:current_user) { create(:user) }

    before do
      session[:user_id] = current_user.id
      session[:last_access_time] = Time.current
    end

    example '会計年度未選択時は、TOPにリダイレクト' do
      get :edit_all
      expect(response).to redirect_to(root_url)
    end

    after do
      session.delete(:user_id)
      session.delete(:last_access_time)
    end
  end
end
