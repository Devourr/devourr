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
    get 'signout', to: 'devise/sessions#destroy', as: :sign_out
    get 'confirm', to: 'users/confirmations#confirm'
    get 'users/password/reset', to: 'users/passwords#new', as: :password_reset

    # /pat/account/edit # just password
    # /pat/edit # name username email etc
    get ':user_name/account/edit', to: 'users/registrations#edit', as: :edit_account_profile,
      constraints: { user_name: /[a-zA-Z0-9._]+/}
    put ':user_name/account', to: 'users/registrations#update', as: :update_account_profile,
      constraints: { user_name: /[a-zA-Z0-9._]+/}

    # adding route for id to avoid `no route matches` error
    get ':id/account/edit', to: 'users/registrations#edit'
  end

  resources :user, only: [:show]

  # place all other routes above here so they are inherited first
  # TODO: come up with an example list of usernames that should not be allowed
  # that match potential route paths like: admin, user, home, discover, etc.

  # to allow for `/my_username1` to access profile
  # need to add constraint for '.' that some user names can have
  # https://guides.rubyonrails.org/routing.html#segment-constraints
  # TODO: write a blog about how TDD saved my ass bc I didn't know
  #   a user_name with a '.' was selecting a format after the split
  #     `user.name3` #=> params {"controller"=>"users", "action"=>"show", "user_name"=>"user", "format"=>"name3"}
  get ':user_name', to: 'users#show', as: :profile,
    constraints: { user_name: /[a-zA-Z0-9._]+/}

  # was getting a 'no route matches' error for `/:id` on user
  get ':id', to: 'users#show'

  get ':user_name/edit', to: 'users#edit', as: :edit_profile,
      constraints: { user_name: /[a-zA-Z0-9._]+/}
  put ':user_name', to: 'users#update', as: :update_profile,
      constraints: { user_name: /[a-zA-Z0-9._]+/}
  # ditto from users#show
  get ':id/edit', to: 'users#edit'


end
