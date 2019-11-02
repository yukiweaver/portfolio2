class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
end

def test
  @users = User.all
end