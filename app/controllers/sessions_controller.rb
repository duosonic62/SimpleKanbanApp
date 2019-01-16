# encoding: utf-8
class SessionsController < ApplicationController
  skip_before_action :require_sign_in!, only: [:new, :create]
  before_action :set_user, only: [:create]
  
  # ログインページを表示するだけなので何もしない
  def new
    if signed_in?
      redirect_to controller: 'tickets', action: 'show'
    end
  end

  # セッションを取得(ログイン)
  def create
    if @user.authenticate(session_params[:password])
      sign_in(@user)
      # トップページに繊維
      redirect_to controller: 'tickets', action: 'show'
    else
      flash.now[:error_messages] = ['Incorrect userid or password']
      render 'new'
    end
  end

  # セッションを破棄(ログアウト)
  def destroy
    sign_out
    redirect_to action: 'new'
  end
  
  private
    def set_user
      @user = User.find_by!(user_id: session_params[:user_id])
    rescue
      flash.now[:error_messages] = ['Incorrect userid or password']
      render 'new'
    end

    def session_params
      params.require(:session).permit(:user_id, :password)
    end

end