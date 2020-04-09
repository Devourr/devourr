Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # redirect www to non-www
  # https://coderwall.com/p/l1uydg/redirect-to-canonical-host-in-rails-4
  if ENV['CANONICAL_HOST'] && !(Rails.env.development? || Rails.env.test?)
    constraints(host: /^(?!#{ENV['CANONICAL_HOST'].gsub('.', '\.')})/i) do
      match '/(*path)' => redirect {
        |params, req| "https://#{ENV['CANONICAL_HOST']}/#{params[:path]}"
      }, via: [:get, :post]
    end
  end

  root 'main#index'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  # helper urls to get user to login page
  devise_scope :user do
    get 'signin', to: 'devise/sessions#new'
    get 'login', to: 'devise/sessions#new'
    get 'signup', to: 'devise/registrations#new'
    get '/signout', to: 'devise/sessions#delete', as: :sign_out
    get 'confirm', to: 'users/confirmations#confirm'
    get 'profile/edit', to: 'users/registrations#edit'
  end

  resources :user, only: [:show]
  get ':user_name', to: 'users#show', as: 'profile'

end
