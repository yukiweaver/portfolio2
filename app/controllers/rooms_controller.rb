class RoomsController < ApplicationController
  before_action :logged_out_user, only:[:first_send, :talk_room]
  def first_send
    @form_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id])
    if params[:event][:data].empty?
      flash.now[:danger] = 'メッセージが空です。'
      render template: "event/first_msg" 
    end
    # メッセージ空でないか確認
    # roomsへインサート（1件）
    # eventsへインサート（3件）
    # トークルームへ遷移
  end

  def talk_room
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
