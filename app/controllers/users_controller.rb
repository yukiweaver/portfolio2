class UsersController < ApplicationController
  before_action :logged_out_user, only:[:search, :mypage, :edit, :update]
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
    @user = User.find(user_id)
    sex_kbn = user_sex_kbn
    user_id = user_id
    page = params[:page]
    search = params[:area_kbn]
    @users = User.search(sex_kbn, user_id, page, search)
  end

  # マイページ
  def mypage
    @user = User.find(user_id)
  end

  # マイページ編集
  def edit
    @user = User.find(user_id)
  end

  # マイページ更新
  def update
    @user = User.find(user_id)
    if @user.update_attributes(mypage_params)
      flash[:success] = 'マイページを更新しました。'
      redirect_to mypage_path
    else
      render action: :edit
    end
  end

  # ユーザーページ
  def user_page
    @from_user = User.find(user_id)
    @user = @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @first_msg_flag = is_first_msg?(@from_user.id, @to_user.id, '9', '9')
    room = Room.get_room_info(@from_user.id, @to_user.id)
    room.each {|r| room = r}
    is_approval_from_or_to = (@from_user.id == room.from_user_id) ? true : false unless room.blank?

    if room.blank? || room.from_user_status == '1' && room.to_user_status == '0' || room.from_user_status == '0' && room.to_user_status == '1' || room.from_user_status == '1' && room.to_user_status == '9' || room.from_user_status == '9' && room.to_user_status == '1'
      @room_status = 'first_msg'
    elsif room.from_user_status == '1' && room.to_user_status == '1' && room.from_user_pair_status == '0' && room.to_user_pair_status == '0'
      @room_status = 'pair_apply'
    elsif # ペア承認条件 (自分がルーム作成者なのか、招待者なのかで変わる)
      if is_approval_from_or_to == true && room.from_user_status == '1' && room.to_user_status == '1' && room.from_user_pair_status == '0' && room.to_user_pair_status == '1'
        @room_status = 'pair_approval'
      elsif is_approval_from_or_to == false && room.from_user_status == '1' && room.to_user_status == '1' && room.from_user_pair_status == '1' && room.to_user_pair_status == '0'
        @room_status = 'pair_approval'
      end
    elsif room.from_user_status == '1' && room.to_user_status == '1' && room.from_user_pair_status == '1' && room.to_user_pair_status == '1'
      @room_status = 'unpair'
    end
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :sex_kbn, :age, :area_kbn)
  end

  def mypage_params
    params.require(:user).permit(
      :name, :sex_kbn, :age, :area_kbn, :profile, :income_kbn, :business_kbn, :free_entry, :image
    )
  end
end
