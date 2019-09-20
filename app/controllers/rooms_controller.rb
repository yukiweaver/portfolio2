class RoomsController < ApplicationController
  before_action :logged_out_user, only:[:first_send, :talk_room]
  def first_send
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    room = Room.new(from_user_id: @from_user.id, to_user_id: @to_user.id)
    # メッセージ空でないか確認
    data = params[:event][:data]
    if data.empty?
      flash.now[:danger] = 'メッセージが空です。'
      render template: "events/first_msg" 
    end
    if room.save
      create_room = Event.event_data(room.id, @from_user.id, @to_user.id, '10', nil)
      entering_room = Event.event_data(room.id, @from_user.id, nil, '11', nil)
      send_message = Event.event_data(room.id, @from_user.id, @to_user.id, '12', data)
      # todo：Eventオブジェクト複数インサート処理入れたい
      redirect_to talk_room_path(@to_user)
    else
      render template: "events/first_msg"
    end
    # roomsへインサート（1件）
    # eventsへインサート（3件）
    # トークルームへ遷移
    # 255文字超える場合、render
  end

  def talk_room
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
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
