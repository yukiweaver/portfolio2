class Event < ApplicationRecord
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_user_id'
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id', optional: true # null許可
  belongs_to :room

  validates :data, length: { maximum: 500 }

  # Eventオブジェクト生成
  def self.event_data(room_id, from_user_id, to_user_id, event_kbn, data)
    Event.new(
      room_id: room_id, 
      from_user_id: from_user_id, 
      to_user_id: to_user_id,
      event_kbn: event_kbn, 
      data: data
    )
  end


end
