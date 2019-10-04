class RoomsController < ApplicationController
  before_action :logged_out_user

  # トークルームページ
  def talk_room
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    room_id = Room.get_room_id(@from_user.id, @to_user.id, '9', '9')
    @events = Event.get_talk_content(room_id, @from_user.id, @to_user.id, '12')
    # binding.pry
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
  end

  # トークルームから入室処理
  def entrance
    if not params[:user_id].match(/\A[0-9]+\z/)
      flash[:danger] = '不正なリクエストです。'
      return redirect_to room_index_path
    end

    @to_user = User.find(user_id)
    @from_user = User.find(params[:user_id])

    room_info = Room.get_room_info(@from_user.id, @to_user.id)
    if room_info.blank?
      flash[:danger] = 'ルームが存在しません。'
      return redirect_to room_index_path
    end

    # すでに自分が10ルーム入室していたらエラー
    room_count = Room.entry_status_count(@to_user.id)
    if room_count >= 10
      flash[:warning] = '入室できるルーム数は10ルームまでです。'
      return redirect_to room_index_path
    end

    room_id = room_info[0][:id]
    room = Room.find(room_id)
    room.to_user_status = '1'
    if room.save
      entering_room = Event.event_data(room_id, @to_user.id, '11')
      if entering_room.save
        flash[:success] = '入室しました。'
        return redirect_to talk_room_path(@from_user)
      else
        flash[:danger] = 'room保存成功、event保存失敗'
        return redirect_to room_index_path
      end
    else
      flash[:danger] = '入室に失敗しました。'
      return redirect_to room_index_path
    end
  end

  # ルーム退出処理
  # from_user_status, to_user_status, from_user_pair_status, to_user_pair_status
  def exit
    @user = User.find(user_id)
    @to_user = User.find(decode(params[:user_id]))
    room = Room.get_room_info(@user.id, @to_user.id)
    if room.blank?
      flash[:warning] = 'ルームが存在しません。'
      return redirect_to room_index_path
    end
    fu_status = room[0][:from_user_status]
    tu_status = room[0][:to_user_status]
    fup_status = room[0][:from_user_pair_status]
    tup_status = room[0][:to_user_pair_status]
    room_id = room[0][:id]
    
    # 一方が1、一方が0のパターン（ペアは両方必ず0しかあり得ない）
    if fu_status == '0' || tu_status == '0'
      if room.update_exit_1()
        exit_event = Event.event_data(room_id, @user.id, '19')
        if exit_event.save
          flash[:info] = '退出しました。'
          return redirect_to room_index_path
        else
          flash[:warning] = 'roomはok、eventでng'
          return redirect_to room_index_path
        end
      else
        flash[:danger] = '退出に失敗しました。'
        return redirect_to room_index_path
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
