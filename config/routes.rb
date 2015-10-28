Rails.application.routes.draw do
  # ユーザTOP画面
  root to: 'top#index', as: :root
  post 'top' => 'top#start', as: :journal_start

  # ユーザログイン管理・ログアウト
  get 'login' => 'sessions#new', as: :login
  post 'session' => 'sessions#create', as: :session
  delete 'session' => 'sessions#destroy'

  # 年度選択
  get 'change_default' => 'change_default#edit', as: :change_default
  post 'change_default' => 'change_default#change'

  # 取引明細(仕訳帳)
  get 'journals' => 'journals#new', as: :journals
  get 'journals/subjects_debit' => 'journals#subjects_debit'
  get 'journals/subjects_credit' => 'journals#subjects_credit'
  get 'journals/list/:id/' => 'journals#list'
  get 'journals/edit/:id/' => 'journals#edit', as: :edit_journal
  get 'journals/copy/:id/' => 'journals#copy'
  post 'journals' => 'journals#create', as: :create_journal
  patch 'journals/:id/' => 'journals#update', as: :journal
  delete 'journals/:id/' => 'journals#destroy', as: :destroy_journal

  ## パスワード変更
  get 'security' => 'securities#edit', as: :change_password
  patch 'security' => 'securities#update', as: :security
  ## 会計年度の管理
  get 'fiscal_year/copy/:id/' => 'fiscal_years#copy', as: :copy_fiscal_year
  resources :fiscal_years, except: [:show]
  ## 会計年度の保守
  get 'fiscal_year_maintenance/:id/' => 'fiscal_years_maintenance#index', as: :fiscal_year_maintenance
  get 'fiscal_year_maintenance/:id/export_journals' => 'fiscal_years_maintenance#export_journals', as: :export_journals
  get 'fiscal_year_maintenance/:id/export_subjects' => 'fiscal_years_maintenance#export_subjects', as: :export_subjects
  get 'fiscal_year_maintenance/:id/export_balances' => 'fiscal_years_maintenance#export_balances', as: :export_balances
  get 'fiscal_year_maintenance/:id/export_badgets' => 'fiscal_years_maintenance#export_badgets', as: :export_badgets
  post 'fiscal_year_maintenance/:id/import_journals' => 'fiscal_years_maintenance#import_journals', as: :import_journals
  post 'fiscal_year_maintenance/:id/import_subjects' => 'fiscal_years_maintenance#import_subjects', as: :import_subjects
  post 'fiscal_year_maintenance/:id/import_balances' => 'fiscal_years_maintenance#import_balances', as: :import_balances
  post 'fiscal_year_maintenance/:id/import_badgets' => 'fiscal_years_maintenance#import_badgets', as: :import_badgets
  delete 'fiscal_year_maintenance/:id/journals' => 'fiscal_years_maintenance#trunc_journals', as: :trunc_journals
  delete 'fiscal_year_maintenance/:id/subjects' => 'fiscal_years_maintenance#trunc_subjects', as: :trunc_subjects
  delete 'fiscal_year_maintenance/:id/balances' => 'fiscal_years_maintenance#trunc_balances', as: :trunc_balances
  delete 'fiscal_year_maintenance/:id/badgets' => 'fiscal_years_maintenance#trunc_badgets', as: :trunc_badgets

  # 科目
  get 'subject' => 'subjects#edit_all', as: :subjects
  get 'subject/new' => 'subjects#new', as: :new_subject
  post 'subject' => 'subjects#create', as: :create_subject
  delete 'subject/:id' => 'subjects#destroy', as: :destroy_subject
  patch 'subject' => 'subjects#update_all'

  # 期首残高
  get 'balance' => 'balances#edit', as: :balances
  patch 'balance' => 'balances#update'
  # 通期予算
  get 'badget' => 'badgets#edit', as: :badgets
  patch 'badget' => 'badgets#update'

  # ユーザ管理(Admin用)
  resources :users, except: [:show]
end
