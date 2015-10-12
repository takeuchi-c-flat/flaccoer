shared_examples 'a protected base controller' do
  describe '#index' do
    example 'ログインフォームにリダイレクト' do
      get :index
      expect(response).to redirect_to(login_url)
    end
  end
end

shared_examples 'a protected base controller for index with id' do
  describe '#index' do
    example 'ログインフォームにリダイレクト' do
      get :index, id: 0
      expect(response).to redirect_to(login_url)
    end
  end
end

shared_examples 'a protected base controller for edit with id' do
  describe '#edit' do
    example 'ログインフォームにリダイレクト' do
      get :edit, id: 0
      expect(response).to redirect_to(login_url)
    end
  end
end

shared_examples 'a protected base controller for new' do
  describe '#new' do
    example 'ログインフォームにリダイレクト' do
      get :new
      expect(response).to redirect_to(login_url)
    end
  end
end
