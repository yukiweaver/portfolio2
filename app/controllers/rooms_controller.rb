class RoomsController < ApplicationController
  before_action :logged_out_user

  # トークルームページ
  def talk_room
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    room_id = Room.get_room_id(@from_user.id, @to_user.id, '9', '9')
    @events = Event.get_talk_content(room_id, @from_user.id, @to_user.id, '12')
  end

  # ルーム一覧
  def room_index
    @user = User.find(user_id)
    # 自分が招待者かつ自分がまだ入室していないルームを取得
    rooms = Room.get_no_entry_room(@user.id)
    if !rooms.blank?
      # ルーム作成者のuser_idを配列で取得して、ユーザーを取得(単数の場合もあり得る)
      users_id = rooms.map{|room| room.from_user_id}
      @users = users_id.map{|user_id| User.where(id: user_id)}.flatten

      # ルームidを配列で取得して、ルームごとの最新のメッセージを取得(単数あり得る)
      rooms_id = rooms.map{|room| room.id}
      @messages = rooms_id.map{|room_id| Event.get_latest_message(room_id)}.flatten
    end
    

    

  end

  private

  def room_params
    params.require(:room).permit(
      :from_user_status, :to_user_status, :exit_date, :close_date, :from_user_pair_status, :to_user_pair_status
    )
  end

  def event_params
    params.require(:event).permit(
      :event_kbn, :data
    )
  end
end
