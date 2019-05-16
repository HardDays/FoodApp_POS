Rails.application.routes.draw do
  # resources :menu_categories
  # resources :restaurants
  # resources :users
  # resources :menu_items

  post 'sign_in' => 'food_app#sign_in'
  get 'get_restaurant' => 'food_app#get_restaurant'
  get   'get_orders' => 'food_app#get_orders'
  post 'create_test_order' => 'food_app#create_test_order'
  post 'clear_menu' => 'food_app#clear_menu'

  get 'get_menu' => 'pos#get_menu'
  post 'sync_menu' => 'pos#sync_menu'
  post 'send_order' => 'pos#send_order'
  post 'check_order' => 'pos#check_order'
end
