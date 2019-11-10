class TopsController < ApplicationController
  before_action :logged_in_user, only: [:top]

  def top
    @user = User.new
  end

  def explain
  end
end
