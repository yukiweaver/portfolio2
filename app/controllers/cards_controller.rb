class CardsController < ApplicationController
  require "payjp"
  before_action :set_card, :logged_out_user

  # カードの登録画面。送信ボタンを押すとcreateアクションへ。
  def new
    card = Card.where(user_id: current_user.id).first
    # redirect_to action: "index" if card.present?
  end


  private
  def set_card
    @card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end
end