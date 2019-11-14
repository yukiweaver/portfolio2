class Event < ApplicationRecord
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_user_id'
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id', optional: true # null許可
  belongs_to :room

  validates :data, length: { maximum: 500 }

  # Eventオブジェクト生成
  def self.event_data(room_id, from_user_id, event_kbn, to_user_id=nil, data=nil)
    Event.new(
      room_id: room_id, 
      from_user_id: from_user_id, 
      to_user_id: to_user_id,
      event_kbn: event_kbn, 
      data: data
    )
  end

  # ２ユーザーのメッセージ内容を返す
  def self.get_talk_content(room_id, from_user_id, to_user_id, event_kbn)
    Event.where('room_id = ? and event_kbn = ?', room_id, event_kbn)
         .where(from_user_id: [from_user_id, to_user_id])
         .where(to_user_id: [from_user_id, to_user_id])
         .order(created_at: 'ASC')
  end

  # 自分からのメッセージ内容を返す
  def self.get_from_user_message(room_id, from_user_id, to_user_id, event_kbn='12')
    from_user_messages = Event.where(
                  'room_id = ? and from_user_id = ? and to_user_id = ? and event_kbn = ?',
                  room_id, from_user_id, to_user_id, event_kbn
                )
    if from_user_messages.blank?
      return []
    end
    return from_user_messages
  end

  # 未読の相手からのメッセージを配列で返す
  def self.get_nonread_to_user_message(room_id, to_user_id, from_user_id, event_kbn='12')
    to_user_messages = Event.where(
                  'room_id = ? and from_user_id = ? and to_user_id = ? and event_kbn = ? and read_flg = ?',
                  room_id, to_user_id, from_user_id, event_kbn, false
                )
    if to_user_messages.blank?
      return []
    end
    return to_user_messages + []
  end


  #　ルームidをキーとして特定のルームで最新メッセージを含むレコード一件取得
  def self.get_latest_message(room_id)
    Event.where('room_id = ? and event_kbn = ?', room_id, '12').order(created_at: 'DESC').limit(1)
  end

  # 2ユーザー間の最新のメッセージを取得（自動更新で使用）
  # param event_id イベントid
  # param user_id ログインユーザーのid
  # param to_user_id 相手ユーザーのid
  def self.get_new_message(event_id, user_id, to_user_id)
    new_message = Event.where(from_user_id: [user_id, to_user_id])
                       .where(to_user_id: [user_id, to_user_id])
                       .where('id > ? and event_kbn = ?', event_id, '12')
  end


end
