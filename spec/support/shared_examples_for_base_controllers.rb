shared_examples 'a protected base controller' do
  describe '#index' do
    example 'ログインフォームにリダイレクト' do
      get :index
      expect(response).to redirect_to(login_url)
    end
  end
end
