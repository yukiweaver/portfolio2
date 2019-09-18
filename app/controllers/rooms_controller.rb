class RoomsController < ApplicationController
  def first_msg
    @user = User.find(user_id)
    @from_user = User.find(user_id)
    @to_user = User.find(Base64.decode64(params[:encoded_id]))
  end
end
