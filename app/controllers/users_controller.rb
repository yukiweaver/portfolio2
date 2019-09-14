class UsersController < ApplicationController
  before_action :logged_out_user, only:[:show]
  # 新規登録処理
  def create
    @user = User.new(user_params)
    if @user.save
      session[:login] = {'user_id' => @user.id, 'sex_kbn' => @user.sex_kbn}
      flash[:success] = '新規登録しました。'
      redirect_to search_path
    else
      flash[:danger] = "登録に失敗しました。"
      redirect_to root_path
    end
  end

  # 検索ページ
  def search
    sex_kbn = user_sex_kbn
    user_id = user_id
    page = params[:page]
    search = params[:area_kbn]
    @users = User.search(sex_kbn, user_id, page, search)
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :sex_kbn, :age, :area_kbn)
  end
end
