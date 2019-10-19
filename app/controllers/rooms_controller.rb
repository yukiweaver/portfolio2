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

    # Todo:退出処理　ペアを考慮していない。Eventの動きが変わってくる。
    
    # 一方が1、一方が0のパターン（ペアは両方必ず0しかあり得ない）完全退出
    if fu_status == '0' || tu_status == '0'
      begin
        ActiveRecord::Base.transaction {
          room.update_exit_1()
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

    # ユーザー間　1,9の場合 完全退出
    if (fu_status == '1' && tu_status == '9') || (fu_status == '9' && tu_status == '1')
      begin
        ActiveRecord::Base.transaction {
          room.update_exit_1()
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
end
