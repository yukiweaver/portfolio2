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

  # マイページ
  def mypage
    user = User.find(user_id)
    @profile = user.profile
    @name = user.name
    @sex = SEX_KBN[user.sex_kbn]
    @age = user.age
    @area = H_AREA_KBN[user.area_kbn]
    @income = H_INCOME_KBN[user.income_kbn]
    @business = H_BUSINESS_KBN[user.business_kbn]
    @free_entry = user.free_entry
  end

  # マイページ編集
  def edit
    @user = User.find(user_id)
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :sex_kbn, :age, :area_kbn)
  end
end
