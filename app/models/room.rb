class Room < ApplicationRecord
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_user_id'
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id'

  has_many :events, dependent: :destroy

  def self.get_room_id(from_user_id, to_user_id, from_user_status, to_user_status)
    room = Room.where(from_user_id: [from_user_id, to_user_id])
               .where(to_user_id: [from_user_id, to_user_id])
               .where.not('from_user_status = ? and to_user_status = ?', 'from_user_status', 'to_user_status')
    room = room + []
    room_id = room[0][:id]
  end
end
