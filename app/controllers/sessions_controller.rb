class SessionsController < ApplicationController
  def new
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:success] = 'ログアウトしました。'
    redirect_to root_path
  end
end
