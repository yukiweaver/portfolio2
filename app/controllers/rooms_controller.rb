class RoomsController < ApplicationController
  before_action -> {
    logged_out_user || card_regist_check(current_user)
  }

  # トークルームページ
  def talk_room
    @from_user = User.find(user_id)
    gon.current_user_id = @from_user.id
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    gon.to_user_image = @to_user.image.url
    gon.to_user_name = @to_user.name
    gon.pair_flg = pair_flg(@from_user.id, @to_user.id)
    @event = Event.new
    room_id = Room.get_room_id(@from_user.id, @to_user.id, '9', '9')
    @events = Event.get_talk_content(room_id, @from_user.id, @to_user.id, '12')
    # binding.pry
    
    respond_to do |format|
      format.html
      format.json {@new_event = Event.get_new_message(params[:event][:id], @from_user.id, @to_user.id)}
    end

    # 未読の相手メッセージを取得してフラグをtrueに変更
    nonread_to_user_messages = Event.get_nonread_to_user_message(room_id, @to_user.id, @from_user.id)
    nonread_to_user_messages.map! {|ntu_msg| ntu_msg if ntu_msg.read_flg = true} unless nonread_to_user_messages.blank?

    begin
      ActiveRecord::Base.transaction {
        # BULK UPDATE
        result = Event.import nonread_to_user_messages, on_duplicate_key_update: [:read_flg]
        # failed_instances : validationに失敗したり、commit失敗でインスタンスを配列にして返す
        if !result.failed_instances.blank?
          raise 'RollBack!!'
        end
        p 'Success!'
      }
      return render action: :talk_room
    rescue => exception
      p 'Failed'
      p exception
      return redirect_to room_index_path, flash: {danger: 'システムエラーが発生しました。'}
    end
  end

  # ルーム一覧
  def room_index
    @user = User.find(user_id)
    # 自分が招待者かつ自分がまだ入室していないルームを取得
    @rooms = Room.get_no_entry_room(@user.id)

    if !@rooms.blank?
      # ルーム作成者のuser_idを配列で取得して、ユーザーを取得(単数の場合もあり得る)
      users_id = @rooms.map{|room| room.from_user_id}
      @users = users_id.map{|user_id| User.where(id: user_id)}.flatten
    end

    # トーク中のユーザーを取得
    @talk_users = Room.get_talk_users(@user.id)

    # 退出中のユーザー取得
    @exit_users = Room.get_exit_users(@user.id)
  end

  # ペア情報
  def pair_info
    @user = User.find(user_id)

    # 自分がペアリクエストを申請しているユーザーを取得
    @apply_users = Room.get_apply_users(@user.id)

    # 自分にペアリクエストを申請しているユーザーを取得
    @approval_users = Room.get_approval_users(@user.id)

    # 自分とペアのユーザーを取得
    @pair_users = Room.get_pair_users(@user.id)
  end

  # トークルームから入室処理
  def entrance
    return redirect_to room_index_path, flash: {warning: '不正なリクエストです。'} if params[:status].blank?
    if not params[:status] == 'first_msg' || params[:status] == 'exit'
      return redirect_to room_index_path, flash: {warning: '不正なリクエストです。'}
    end
    @to_user = User.find(user_id)
    @from_user = User.find(decode(params[:encoded_id]))

    # ユーザー未取得
    return redirect_to room_index_path, flash: {warning: '不正なリクエストです。'} if @from_user.blank?

    # ルーム未取得
    room_info = Room.get_room_info(@from_user.id, @to_user.id)
    return redirect_to room_index_path, flash: {danger: 'ルームが存在しません。'} if room_info.blank?

    # すでに自分が10ルーム入室していたらエラー
    room_count = Room.entry_status_count(@to_user.id)
    return redirect_to room_index_path, flash: {warning: '入室できるルーム数は10ルームまでです。'} if room_count >= 10

    room = nil
    room_info.each {|r| room = r}

    # 相手からの初回メッセージから入室するパターン
    room.to_user_status = '1' if params[:status] == 'first_msg'

    # 退出中から入室するパターン
    if params[:status] == 'exit'
      room.to_user_status = '1' if room.to_user_id == @to_user.id
      room.from_user_status = '1' if room.from_user_id == @to_user.id
    end

    begin
      ActiveRecord::Base.transaction {
        room.save!
        entering_room = Event.event_data(room.id, @to_user.id, '11')
        entering_room.save!
        p 'Success!'
      }
      # トランザクション成功
      return redirect_to talk_room_path(@from_user), flash: {success: '入室しました。'}
    rescue => exception
      p 'Failed'
      p exception
      return redirect_to room_index_path, flash: {danger: '入室に失敗しました。'}
    end
  end

  # ルーム退出処理
  # from_user_status, to_user_status, from_user_pair_status, to_user_pair_status
  def exit
    @user = User.find(user_id)
    @to_user = User.find(decode(params[:encoded_id]))
    room = Room.get_room_info(@user.id, @to_user.id)
    if room.blank?
      flash[:warning] = 'ルームが存在しません。'
      return redirect_to room_index_path
    end
    if room.count != 1
      flash[:warning] = 'ルーム数が不正です。'
      return redirect_to room_index_path
    end
    room.each {|r| room = r}
    fu_status = room.from_user_status
    tu_status = room.to_user_status
    fup_status = room.from_user_pair_status
    tup_status = room.to_user_pair_status
    fu_id = room.from_user_id
    tu_id = room.to_user_id
    room_id = room.id
    is_from_user = (@user.id == fu_id) ? true : false
    pair_status = is_pair_status(fup_status, tup_status)
    
    # 一方が1、一方が0のパターン（ペアは両方必ず0しかあり得ない）
    if fu_status == '0' || tu_status == '0'
      begin
        ActiveRecord::Base.transaction {
          room.update_exit_1(is_from_user)
          exit_event = Event.event_data(room_id, @user.id, '19')
          exit_event.save!
          p 'Success!'
        }
        return redirect_to room_index_path, flash: {info: '退出しました。'}
      rescue => exception
        p 'Failed'
        p exception
        return redirect_to room_index_path, flash: {danger: '退出に失敗しました。'}
      end
    end

    # ユーザー間　１、１の場合（ペアはいかなる場合でも0,0に更新）
    if fu_status == '1' && tu_status == '1'
      begin
        ActiveRecord::Base.transaction {
          room.update_exit_2(is_from_user)
          events = []
          cancel_event = Event.event_data(room_id, @user.id, '28') if pair_status == '1'
          unpair_event = Event.event_data(room_id, @user.id, '29', @to_user.id) if pair_status == '2'
          exit_event = Event.event_data(room_id, @user.id, '19')
          events.push(cancel_event, unpair_event, exit_event)
          events = events.compact # 配列にnilがあった場合に取り除く
          # BULK INSERT
          result = Event.import events
          # failed_instances : validationに失敗したり、commit失敗でインスタンスを配列にして返す
          if !result.failed_instances.blank?
            raise 'RollBack!!'
          end
          p 'Success!'
        }
        return redirect_to room_index_path, flash: {info: '退出しました。'}
      rescue => exception
        p 'Failed'
        p exception
        return redirect_to room_index_path, flash: {danger: '退出に失敗しました。'}
      end
    end

    # ユーザー間　1,9の場合 完全退出
    if (fu_status == '1' && tu_status == '9') || (fu_status == '9' && tu_status == '1')
      begin
        ActiveRecord::Base.transaction {
          room.update_exit_3()
          exit_event = Event.event_data(room_id, @user.id, '19')
          exit_event.save!
          p 'Success!'
        }
        return redirect_to room_index_path, flash: {info: '退出しました。'}
      rescue => exception
        p 'Failed'
        p exception
        return redirect_to room_index_path, flash: {danger: '退出に失敗しました。'}
      end
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

  # ルームのペア状況を取得
  def is_pair_status(from_user_pair_status, to_user_pair_status)
    if from_user_pair_status == '2' && to_user_pair_status == '2'
      is_pair_status = '2'
    elsif from_user_pair_status == '1' && to_user_pair_status == '0' || from_user_pair_status == '0' && to_user_pair_status == '1'
      is_pair_status = '1'
    elsif from_user_pair_status == '0' && to_user_pair_status == '0'
      is_pair_status = '0'
    end
    return is_pair_status
  end
end
