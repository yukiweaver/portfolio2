class EventsController < ApplicationController
  before_action :logged_out_user, only:[:first_msg]
  def first_msg
    @user = User.find(user_id)
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
    @event = Event.new
  end
end
