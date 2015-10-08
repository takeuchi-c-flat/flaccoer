Rails.application.routes.draw do
  ### ユーザTOP画面
  root to: 'top#index', as: :root
  post 'top' => 'top#start', as: :journal_start

  ### ユーザログイン管理
  get 'login' => 'sessions#new', as: :login
  post 'session' => 'sessions#create', as: :session
  delete 'session' => 'sessions#destroy'

  ## ユーザ用設定画面
  get 'configure' => 'configure#index', as: :configure
  # パスワード変更
  get 'security' => 'securities#edit', as: :change_password
  patch 'security' => 'securities#update', as: :security
  # 会計年度の管理
  get 'fiscal_year_copy/:id/new' => 'fiscal_years_copy#new', as: :fiscal_year_copy
  post 'fiscal_year_copy/:id/' => 'fiscal_years_copy#create', as: :fiscal_year_clone
  get 'fiscal_year_maintenance/:id/' => 'fiscal_years_maintenance#index', as: :fiscal_year_maintenance
  delete 'fiscal_year_maintenance/:id/journals' => 'fiscal_years_maintenance#trunc_journals', as: :trunc_journals
  delete 'fiscal_year_maintenance/:id/balances' => 'fiscal_years_maintenance#trunc_balances', as: :trunc_balances
  delete 'fiscal_year_maintenance/:id/badgets' => 'fiscal_years_maintenance#trunc_badgets', as: :trunc_badgets
  resources :fiscal_years, except: [:show]

  ### 科目・期首残高・予算画面
  # 期首残高
  get 'subject/:id' => 'subjects#edit', as: :subjects
  post 'subject/:id' => 'subjects#update'
  # 期首残高
  get 'balance' => 'balances#edit', as: :balances
  patch 'balance' => 'balances#update'
  # 予算画面
  get 'badget' => 'badgets#edit', as: :badgets
  patch 'badget' => 'badgets#update'

  ### ユーザ管理(Admin用)
  resources :users, except: [:show]
end
