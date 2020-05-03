shared_examples 'a protected admin base controller' do
  describe '#index' do
    example 'ログインフォームにリダイレクト' do
      process :index, method: :get
      expect(response).to redirect_to(login_url)
    end
  end
end
