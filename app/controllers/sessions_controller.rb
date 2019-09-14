class SessionsController < ApplicationController
  # ログイン処理
  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:success] = "ログインしました。"
      redirect_to user_path(id: user_id)
    else
      flash[:danger] = 'ログインに失敗しました。'
      redirect_to root_path
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:info] = 'ログアウトしました。'
    redirect_to root_path
  end
end
