class UsersController < ApplicationController
  skip_before_action :require_sign_in!, only: [:new, :create]
  
  def new
    @user = User.new(flash[:user])
  end

  def create
    user = User.new(user_params)
    if user.save
        redirect_to login_path
    else
      # 書き込み失敗
      flash[:error_messages] = user.errors.full_messages
      flash[:user] = user
      redirect_back(fallback_location: root_path)
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :user_id, :password, :password_confirmation)
    end
end
