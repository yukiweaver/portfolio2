class RoomsController < ApplicationController
  before_action :logged_out_user, only:[:talk_room]

  # トークルームページ
  def talk_room
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
    room_id = Room.get_room_id(@from_user.id, @to_user.id, '9', '9')
    @events = Event.get_talk_content(room_id, @from_user.id, @to_user.id, '12')
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
