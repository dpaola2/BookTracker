Rails.application.routes.draw do
  devise_for :users
  
  resources :books
  resources :shelves
  
  root "books#index"
end
