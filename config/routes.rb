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
  
  root "shelves#index"
end
