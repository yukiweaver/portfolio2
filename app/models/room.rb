class Room < ApplicationRecord
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_user_id'
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id'

  has_many :events, dependent: :destroy

  # ２ユーザーのルーム情報を配列で返す（複数レコード取得できた場合、バグなので修正必要）
  def self.get_room_info(from_user_id, to_user_id, from_user_status='9', to_user_status='9')
    room = Room.where(from_user_id: [from_user_id, to_user_id])
               .where(to_user_id: [from_user_id, to_user_id])
               .where.not('from_user_status = ? and to_user_status = ?', 'from_user_status', 'to_user_status')
    if room.blank?
      return []
    end
    return room + []
  end

  # ２ユーザーのルームidを返す
  def self.get_room_id(from_user_id, to_user_id, from_user_status='9', to_user_status='9')
    room = Room.get_room_info(from_user_id, to_user_id, from_user_status, to_user_status)
    if room.blank?
      return
    end
    return room[0][:id]
  end

  # 初回メッセージ送信済みか判定
  def is_first_msg?(from_user_id, to_user_id, from_user_status='9', to_user_status='9')
    room = Room.get_room_info(from_user_id, to_user_id, from_user_status, to_user_status)
    if room.blank?
      return false
    end
  end
end
