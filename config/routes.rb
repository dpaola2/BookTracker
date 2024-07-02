Rails.application.routes.draw do
  get 'defaults/create'
  devise_for :users
  
  resources :books do
    resources :isbn_searches, only: [:create] do
      resources :assignments, only: [:create]
    end
  end
  
  resources :shelves do
    resources :defaults, only: [:create]
  end

  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create]
      resources :books, only: [:index]
    end
  end
  
  root "shelves#index"
end
