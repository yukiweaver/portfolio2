class SessionsController < ApplicationController
  # ログイン処理
  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:login] = {'user_id' => @user.id, 'sex_kbn' => @user.sex_kbn, 'card_regist_flg' => @user.card_regist_flg}
      redirect_to search_path
    else
      flash[:danger] = 'ログインに失敗しました。'
      redirect_to root_path
    end
  end

  def destroy
    session.delete(:login)
    @current_user = nil
    redirect_to root_path
  end
end
