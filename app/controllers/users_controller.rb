class UsersController < ApplicationController
  # 新規登録処理
  def create
    @user = User.new(user_params)
    if @user.save
      # session[:user_id] = user.id
      flash[:success] = '新規登録しました。'
      redirect_to @user
    else
      flash[:danger] = "登録に失敗しました。"
      redirect_to root_path
    end
  end

  # 検索ページ
  def show
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :sex_kbn, :age, :area_kbn)
  end
end
