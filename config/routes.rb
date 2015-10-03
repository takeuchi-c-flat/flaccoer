Rails.application.routes.draw do
  # ユーザTOP画面
  root to: 'top#index'

  # ユーザログイン管理
  get 'login' => 'sessions#new', as: :login
  post 'session' => 'sessions#create', as: :session
  delete 'session' => 'sessions#destroy'

  # ユーザ用設定画面
  get 'configure' => 'configure#index', as: :configure
  get 'security' => 'securities#edit', as: :change_password
  patch 'security' => 'securities#update', as: :security
  resources :fiscal_years, except: [:show]

  # ユーザ管理(Admin用)
  resources :users, except: [:show]
end
