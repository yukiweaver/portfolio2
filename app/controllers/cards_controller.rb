class CardsController < ApplicationController
  require "payjp"
  before_action :set_card, :set_user, :logged_out_user

  # カードの登録画面
  # 送信ボタンを押すとcreateアクションへ（createアクションの前にjsの処理が走る）
  def new
    card = Card.where(user_id: current_user.id).first
    return redirect_to action: "index" if card.present?
  end

  #PayjpとCardのデータベースを作成
  def create
    Payjp.api_key = 'sk_test_5a4363c143c9b9bc97feaa74'

    if params['payjp-token'].blank?
      return redirect_to action: "new"
    end

    # 既に年齢認証フラグがtrueならリダイレクト
    if @user.card_regist_flg
      return redirect_to action: "new"
    end

    # トークンが正常に発行されていたら、顧客情報をPAY.JPに登録（JSON）
    customer = Payjp::Customer.create(
      description: '登録テスト', # 無くてもOK。PAY.JPの顧客情報に表示する概要
      email: current_user.email,
      card: params['payjp-token'], # 直前のnewアクションで発行され、送られてくるトークンをここで顧客に紐付けて永久保存
      metadata: {user_id: current_user.id} # 無くてもOK。
    )

    # ログインユーザーの年齢認証フラグ更新
    @user.card_regist_flg = true
    @card = Card.card_data(@user.id, customer.id, customer.default_card)

    begin
      ActiveRecord::Base.transaction {
        @user.save!
        @card.save!
        p 'Success!'
      }
      # トランザクション成功
      return redirect_to card_index_path
    rescue => exception
      p 'Failed'
      p exception
      return redirect_to action: "create"
    end
  end

  # 登録カード一覧
  def index
    if @card.blank?
      return redirect_to action: 'new'
    end

    Payjp.api_key = "sk_test_5a4363c143c9b9bc97feaa74"
    customer = Payjp::Customer.retrieve(@card.customer_id)
    @card_information = customer.cards.retrieve(@card.card_id)
    @card_brand = @card_information.brand
    @card_src = ApplicationHelper::H_CARD_BRAND[@card_brand]
    @exp_month = @card_information.exp_month.to_s
    @exp_year = @card_information.exp_year.to_s.slice(2,3)
  end

  # クレカ削除
  def delete
    Payjp.api_key = "sk_test_5a4363c143c9b9bc97feaa74"
    customer = Payjp::Customer.retrieve(@card.customer_id)

    # ログインユーザーの年齢認証フラグを更新
    @user.card_regist_flg = false

    customer.delete

    begin
      ActiveRecord::Base.transaction {
        @user.save!
        @card.destroy!
        p 'Success!'
      }
      # トランザクション成功
      return redirect_to new_card_path, flash: {info: '削除しました。'}
    rescue => exception
      p 'Failed'
      p exception
      return redirect_to card_index_path, flash: {danger: '削除に失敗しました。'}
    end
  end


  private
  def set_card
    @card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end

  def set_user
    @user = User.find(user_id) if User.find(user_id).present?
  end
end