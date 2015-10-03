shared_examples 'a protected admin base controller' do
  describe '#index' do
    example 'ログインフォームにリダイレクト' do
      get :index
      expect(response).to redirect_to(login_url)
    end
  end
end
