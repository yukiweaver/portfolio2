Rails.application.routes.draw do
  # get 'sessions/new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'tops#top'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get    '/search',  to: 'users#search'
  get    '/mypage',  to: 'users#mypage'
  get    '/mypage/edit',  to: 'users#edit'
  patch   '/mypage/:id/',  to: 'users#update',  as: 'mypage_update'
  resources :users
end
