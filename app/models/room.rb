class Room < ApplicationRecord
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_user_id'
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id'

  has_many :events, dependent: :destroy

  # ２ユーザーのルーム情報を配列で返す（複数レコード取得できた場合、バグなので修正必要）
  def self.get_room_info(from_user_id, to_user_id, from_user_status='9', to_user_status='9')
    room = Room.where(from_user_id: [from_user_id, to_user_id])
               .where(to_user_id: [from_user_id, to_user_id])
               .where.not('from_user_status = ? and to_user_status = ?', from_user_status, to_user_status)
    if room.blank?
      return []
    end
    return room + []
  end

  # ２ユーザーのルームidを返す
  def self.get_room_id(from_user_id, to_user_id, from_user_status='9', to_user_status='9')
    room = Room.get_room_info(from_user_id, to_user_id, from_user_status, to_user_status)
    if room.blank?
      return false
    end
    return room[0][:id]
  end

  # ルームに招待されているかつ、自分が入室していないルームを取得（降順）
  def self.get_no_entry_room(to_user_id)
    rooms = Room.where('from_user_status = ? and to_user_status = ? and to_user_id = ?',
                       '1', '0', to_user_id).order(created_at: 'DESC')
    if rooms.blank?
      return []
    end
    return rooms
  end

  # ユーザーidをキーとして、そのユーザーの入室しているルーム情報を返す（降順）
  def self.get_entrance_room(user_id)
    Room.where(from_user_id: user_id, from_user_status: '1').or(Room.where(to_user_id: user_id, to_user_status: '1')).order(created_at: 'DESC')
  end

  # ユーザーidをキーとして、そのユーザーのルーム入室状態の数を返す
  def self.entry_status_count(user_id)
    Room.get_entrance_room(user_id).count
  end

  # 入室中のルーム取得後、トーク中のユーザーを取得
  def self.get_talk_users(user_id)
    entrance_rooms = self.get_entrance_room(user_id)
    if entrance_rooms.blank?
      return []
    end
    talk_users = []
    entrance_rooms.each do |room|
      if user_id == room.from_user_id
        user = User.find(room.to_user_id)
      else
        user = User.find(room.from_user_id)
      end
      talk_users.push(user)
    end
    return talk_users
  end

  # 退出処理更新（from_user_status、to_user_statusどちらか一方が「１」、一方が「0」の場合）
  # 修正必要あり 1,9or9,1があり得る
  def update_exit_1
    self.update_attributes!(
      from_user_status: '9',
      to_user_status: '9',
      exit_date: Time.now,
      close_date: Time.now,
      from_user_pair_status: '0',
      to_user_pair_status: '0'
    )
  end

  # 退出処理更新（from_user_status、to_user_statusともに「１」の場合）
  # @param is_from_user: boolean
  def update_exit_2(is_from_user)
    if is_from_user
      self.update_attributes!(
        from_user_status: '9',
        to_user_status: '1',
        exit_date: Time.now,
        from_user_pair_status: '0',
        to_user_pair_status: '0'
      )
    else
      self.update_attributes!(
        from_user_status: '1',
        to_user_status: '9',
        exit_date: Time.now,
        from_user_pair_status: '0',
        to_user_pair_status: '0'
      )
    end
  end

  # 退出中のユーザーを取得（単数あり）
  def self.get_exit_users(user_id)
    exit_rooms = self.where(from_user_status: '9', to_user_status: '1', from_user_id: user_id)
                .or(Room.where(from_user_status: '1', to_user_status: '9', to_user_id: user_id))
                .order(exit_date: 'DESC')
    return [] if exit_rooms.blank?
    exit_users_id = []
    exit_rooms.each do |e_room|
      exit_users_id << e_room.from_user_id if e_room.from_user_id != user_id
      exit_users_id << e_room.to_user_id if e_room.to_user_id != user_id
    end
    users = exit_users_id.map {|uid| User.find(uid)}
    return users
  end

  # ペアリクエスト
  # @param is_from_user: boolean
  def update_pair_apply(is_from_user)
    if is_from_user
      return self.update_attributes!(from_user_pair_status: '1', to_user_pair_status: '0')
    else
      return self.update_attributes!(from_user_pair_status: '0', to_user_pair_status: '1')
    end
  end

  # ペア承認
  def update_pair_approval
    return self.update_attributes!(from_user_pair_status: '2', to_user_pair_status: '2')
  end

  # ログインユーザーがペアリクエストしているルームを取得
  # @param user_id ログインユーザーのid
  def self.get_apply_rooms(user_id)
    rooms = Room.where(from_user_id: user_id, from_user_pair_status: '1', to_user_pair_status: '0')
            .or(Room.where(to_user_id: user_id, from_user_pair_status: '0', to_user_pair_status: '1'))
            .order(updated_at: 'DESC')
    if rooms.blank?
      return []
    end
    return rooms
  end

  # ログインしているユーザーがペアリクエストしているユーザーを配列で取得
  # @param user_id ログインユーザーのid
  def self.get_apply_users(user_id)
    rooms = Room.get_apply_rooms(user_id)
    if rooms.blank?
      return []
    end
    users_id = []
    rooms.each do |r|
      users_id << r.from_user_id if user_id == r.to_user_id
      users_id << r.to_user_id if user_id == r.from_user_id
    end
    users = users_id.map {|user_id| User.find(user_id)}
    return users
  end

  # ログインしているユーザーにペアリクエストがきているルームを取得
  def self.get_approval_rooms(user_id)
    rooms = Room.where(from_user_id: user_id, from_user_pair_status: '0', to_user_pair_status: '1')
            .or(Room.where(to_user_id: user_id, from_user_pair_status: '1', to_user_pair_status: '0'))
            .order(updated_at: 'DESC')
    if rooms.blank?
      return []
    end
    return rooms
  end

  # ログインしているユーザーにペアリクエストを申請しているユーザーを配列で取得
  def self.get_approval_users(user_id)
    rooms = Room.get_approval_rooms(user_id)
    if rooms.blank?
      return []
    end
    users_id = []
    rooms.each do |r|
      users_id << r.from_user_id if user_id == r.to_user_id
      users_id << r.to_user_id if user_id == r.from_user_id
    end
    users = users_id.map {|user_id| User.find(user_id)}
    return users
  end
end