class SessionsController < ApplicationController
  # ログイン処理
  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:login] = {'user_id' => @user.id, 'sex_kbn' => @user.sex_kbn}
      # binding.pry
      flash[:success] = "ログインしました。"
      redirect_to search_path
    else
      flash[:danger] = 'ログインに失敗しました。'
      redirect_to root_path
    end
  end

  def destroy
    session.delete(:login)
    @current_user = nil
    flash[:info] = 'ログアウトしました。'
    redirect_to root_path
  end
end
