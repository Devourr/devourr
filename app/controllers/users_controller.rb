class UsersController < ApplicationController

  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      # app/controllers/concerns/email_security.rb
      flash[:success] = user_update_message_success
      redirect_to profile_path(@user.user_name)
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to :edit_profile, user_name: @user.user_name
    end
  end


  private

  def set_user
    @user = User.find_by_user_name(params[:user_name])
    if @user.nil?
      redirect_to root_path, notice: 'Requested page is not available.'
    end
  end

  def user_params
    params.require(:user).permit(:name, :user_name, :email)
  end

end
