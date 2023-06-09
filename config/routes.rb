Rails.application.routes.draw do
  devise_for :users
  
  resources :books do
    resources :isbn_searches, only: [:create] do
      resources :assignments, only: [:create]
    end
  end
  
  resources :shelves
  
  root "books#index"
end
