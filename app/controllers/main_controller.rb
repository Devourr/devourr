class MainController < ApplicationController

  def index
  end

  def letsencrypt
    render plain: ENV['LETSENCRYPT_KEY']
  end

end
