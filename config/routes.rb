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

end
