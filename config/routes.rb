Rails.application.routes.draw do
  # resources :menu_categories
  # resources :restaurants
  # resources :users
  # resources :menu_items

  post 'sign_in' => 'food_app#sign_in'

  get 'iiko_menu' => 'iiko#get_menu'
  post 'upload_iiko' => 'iiko#sync_menu'
end
