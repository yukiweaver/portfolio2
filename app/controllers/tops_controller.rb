class TopsController < ApplicationController
  def top
    @user = User.new
  end
end
