Rails.application.routes.draw do
  # ユーザTOP画面
  root 'top#index'

  # ユーザログイン管理
  get 'login' => 'sessions#new', as: :login
  post 'session' => 'sessions#create', as: :session
  delete 'session' => 'sessions#destroy'

  # ユーザ管理(Admin用)
  resources :users
end
