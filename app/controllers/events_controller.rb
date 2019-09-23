class EventsController < ApplicationController
  before_action :logged_out_user, only:[:first_msg]
  # 初回メッセージページ
  def first_msg
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
  end

  # 初回メッセージ送信処理
  def first_send
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    room = Room.new(from_user_id: @from_user.id, to_user_id: @to_user.id)
    # メッセージ空ならエラー
    data = params[:event][:data]
    if data.empty?
      flash[:danger] = 'メッセージが空です。'
      return redirect_to first_msg_path(@to_user)
    end
    # 500文字超える場合、エラー
    if data.length > 500
      flash[:danger] = 'メッセージが長いです。'
      return redirect_to first_msg_path(@to_user)
    end
    if room.save
      events = []
      create_room = Event.event_data(room.id, @from_user.id, @to_user.id, '10', nil)
      entering_room = Event.event_data(room.id, @from_user.id, nil, '11', nil)
      send_message = Event.event_data(room.id, @from_user.id, @to_user.id, '12', data)
      events.push(create_room, entering_room, send_message)
      # BULK INSERT
      if Event.import events
        flash[:success] = 'event保存OK'
        return redirect_to talk_room_path(@to_user)
      end
    else
      return render template: "events/first_msg"
    end
  end

  # トークルームからメッセージ送信処理
  def send_message
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    # メッセージ空ならエラー
    data = params[:event][:data]
    if data.empty?
      flash[:danger] = 'メッセージが空です。'
      return redirect_to talk_room_path(@to_user)
    end
    # 500文字超える場合、エラー
    if data.length > 500
      flash[:danger] = 'メッセージが長いです。'
      return redirect_to talk_room_path(@to_user)
    end
    
    room_id = Room.get_room_id(@from_user_id, @to_user_id, '9', '9')
    data = params[:event][:data]
    send_message = Event.event_data(room_id, @from_user.id, @to_user.id, '12', data)
    if send_message.save
      return redirect_to talk_room_path(@to_user)
    else
      flash[:danger] = '送信できませんでした。'
      return redirect_to talk_room_path(@to_user)
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
