Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'main#index'

  # SSL with Let's Encrypt
  # https://collectiveidea.com/blog/archives/2016/01/12/lets-encrypt-with-a-rails-app-on-heroku
  get '/.well-known/acme-challenge/:id' => 'main#letsencrypt'

end
