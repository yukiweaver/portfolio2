class EventsController < ApplicationController
  before_action :logged_out_user
  # 初回メッセージページ
  def first_msg
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    if is_first_msg?(@from_user.id, @to_user.id, '9', '9')
      return redirect_to user_page_path(@to_user)
    end
  end

  # 初回メッセージ送信処理
  def first_send
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new

    # 初回メッセージ済みならリダイレクト
    if is_first_msg?(@from_user.id, @to_user.id, '9', '9')
      return redirect_to user_page_path(@to_user)
    end
    
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

    begin
      ActiveRecord::Base.transaction {
        room.save!
        events = []
        create_room = Event.event_data(room.id, @from_user.id, '10', @to_user.id)
        entering_room = Event.event_data(room.id, @from_user.id, '11')
        send_message = Event.event_data(room.id, @from_user.id, '12', @to_user.id, data)
        events.push(create_room, entering_room, send_message)

        # BULK INSERT
        result = Event.import events
        # failed_instances : validationに失敗したり、commit失敗でインスタンスを配列にして返す
        if !result.failed_instances.blank?
          raise 'RollBack!!'
        end
      }
      return redirect_to talk_room_path(@to_user), flash: {success: 'メッセージを送信しました。'}
    rescue => exception
      p 'Failed'
      p exception
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
    
    room_id = Room.get_room_id(@from_user.id, @to_user.id, '9', '9')
    data = params[:event][:data]
    send_message = Event.event_data(room_id, @from_user.id, '12', @to_user.id, data)
    if send_message.save
      return redirect_to talk_room_path(@to_user)
    else
      flash[:danger] = '送信できませんでした。'
      return redirect_to talk_room_path(@to_user)
    end
  end

  # ペアリクエスト申請　処理
  def apply
    @user = User.find(user_id)
    @to_user = User.find(decode(params[:encoded_id]))
    room = Room.get_room_info(@user.id, @to_user.id)
    room.each {|r| room = r}
    return redirect_to user_page_path(@to_user), flash: {danger: 'ルームが存在しません。'} if room.blank?

    fu_id = room.from_user_id  # ルーム作成者のid
    fu_status = room.from_user_status  # 作成者ステータス
    tu_status = room.to_user_status  # 招待者ステータス
    p_fu_status = room.from_user_pair_status  # 作成者のペアステータス
    p_tu_status = room.to_user_pair_status  # 招待者のペアステータス
    is_from_user = (@user.id == fu_id) ? true : false

    # ステータスに誤りがあればエラー
    if not fu_status == '1' && tu_status == '1' && p_fu_status == '0' && p_tu_status = '0'
      return redirect_to user_page_path(@to_user), flash: {danger: 'ペアリクエストに失敗しました。'}
    end

    # 画像と年収設定していなかったらエラー
    if @user.income_kbn.blank? || @user.image.blank?
      return redirect_to mypage_edit_path, flash: {warning: 'アイコン画像および年収を編集してください。'}
    end

    # 更新
    begin
      ActiveRecord::Base.transaction {
        room.update_pair_apply(is_from_user)
        pair_apply = Event.event_data(room.id, @user.id, '20', @to_user.id)
        pair_apply.save!
        p 'Success'
        # raise 'RollBack!!'
      }
      return redirect_to user_page_path(@to_user), flash: {success: 'ペアリクエストを送りました。'}
    rescue => exception
      p 'Failed'
      p exception
      return redirect_to user_page_path(@to_user), flash: {danger: 'ペアリクエストに失敗しました。'}
    end
  end

  # ペア承認 処理
  def approval
    @user = User.find(user_id)
    @to_user = User.find(decode(params[:encoded_id]))
    room = Room.get_room_info(@user.id, @to_user.id)
    room.each {|r| room = r}
    return redirect_to user_page_path(@to_user), flash: {danger: 'ルームが存在しません。'} if room.blank?

    fu_id = room.from_user_id  # ルーム作成者のid
    fu_status = room.from_user_status  # 作成者ステータス
    tu_status = room.to_user_status  # 招待者ステータス
    p_fu_status = room.from_user_pair_status  # 作成者のペアステータス
    p_tu_status = room.to_user_pair_status  # 招待者のペアステータス
    is_from_user = (@user.id == fu_id) ? true : false

    # ステータスに誤りがあればエラー
    if is_from_user
      if not fu_status == '1' && tu_status == '1' && p_fu_status == '0' && p_tu_status = '1'
        return redirect_to user_page_path(@to_user), flash: {danger: 'ペア承認に失敗しました。'}
      end
    else
      if not fu_status == '1' && tu_status == '1' && p_fu_status == '1' && p_tu_status = '0'
        return redirect_to user_page_path(@to_user), flash: {danger: 'ペア承認に失敗しました。'}
      end
    end

    # 画像と年収設定していなかったらエラー
    if @user.income_kbn.blank? || @user.image.blank?
      return redirect_to mypage_edit_path, flash: {warning: 'アイコン画像および年収を編集してください。'}
    end

    # 更新
    begin
      ActiveRecord::Base.transaction {
        room.update_pair_approval()
        pair_approval = Event.event_data(room.id, @user.id, '21', @to_user.id)
        pair_approval.save!
        p 'Success'
      }
      return redirect_to user_page_path(@to_user), flash: {success: 'ペア承認しました。'}
    rescue => exception
      p 'Failed'
      p exception
      return redirect_to user_page_path(@to_user), flash: {danger: 'ペア承認に失敗しました。'}
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
