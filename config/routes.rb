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
  patch  '/mypage/update',  to: 'users#update',  as: 'mypage_update'
  get    '/user_page/:encoded_id',    to: 'users#user_page',  as: 'user_page'
  get    '/first_msg/:encoded_id',    to: 'events#first_msg',  as: 'first_msg'
  post   '/first_msg/first_send/:encoded_id',  to: 'events#first_send',  as: 'first_send'
  get    '/room/talk_room/:encoded_id',  to: 'rooms#talk_room',  as: 'talk_room'
  post   '/event/send_message/:encoded_id',  to: 'events#send_message',  as: 'send_message'
  get    '/room/room_index',  to:  'rooms#room_index',  as: 'room_index'
  post   '/room/entrance',  to:  'rooms#entrance',  as:  'entrance'
  resources :users
end
