Rails.application.routes.draw do
  # resources :menu_categories
  # resources :restaurants
  # resources :users
  # resources :menu_items

  post 'sign_in' => 'food_app#sign_in'

  get 'get_menu' => 'pos#get_menu'
  post 'sync_menu' => 'pos#sync_menu'
  post 'send_order' => 'pos#send_order'
end
