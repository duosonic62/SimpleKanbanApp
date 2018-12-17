class ZzzController < ApplicationController
  def top
    @user = current_user
  end
end