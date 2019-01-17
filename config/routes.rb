Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :tickets
  # ユーザ登録
  get 'users/new'
  post 'users/create'

  # ログイン/ログアウト
  root 'sessions#new'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # チケット
  get 'top', to: 'tickets#show'
  get 'detail', to: 'tickets#detail'
  get 'create', to: 'tickets#new'
  post 'create', to: 'tickets#create'
  get 'edit', to: 'tickets#edit'
  get 'upgrade', to: 'tickets#upgrade'
  get 'downgrade', to: 'tickets#downgrade'
  patch 'update', to: 'tickets#update'
  delete 'destroy', to: 'tickets#destroy'
end
