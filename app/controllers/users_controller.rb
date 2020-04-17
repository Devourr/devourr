class UsersController < ApplicationController

  before_action :set_user

  def show
  end

  def edit
  end

  private

  def set_user
    @user = User.find_by_user_name(params[:user_name])
    if @user.nil?
      redirect_to root_path, notice: 'Requested page is not available.'
    end
  end

end
