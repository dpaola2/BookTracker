Rails.application.routes.draw do
  get 'defaults/create'
  devise_for :users
  
  resources :books do
    resources :isbn_searches, only: [:create] do
      resources :assignments, only: [:create]
    end
  end

  resources :book_searches, only: [:index]
  
  resources :shelves do
    resources :defaults, only: [:create]
  end

  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create]
      resources :books, only: [:index, :show]
      resources :shelves, only: [:index, :show]
    end
  end

  resources :api_docs, only: [:index]
  
  root "shelves#index"
end
