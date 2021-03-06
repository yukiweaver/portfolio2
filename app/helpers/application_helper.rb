module ApplicationHelper
  AREA_KBN = [
    ['北海道', '1'],['青森県', '2'],['岩手県', '3'],['宮城県', '4'], ['秋田県', '5'], ['山形県', '6'],
    ['福島県', '7'],['茨城県', '8'],['栃木県', '9'],['群馬県', '10'],['埼玉県', '11'],['千葉県', '12'],
    ['東京都', '13'],['神奈川県', '14'],['新潟県', '15'],['富山県', '16'],['石川県', '17'],['福井県', '18'],
    ['山梨県', '19'],['長野県', '20'],['岐阜県', '21'],['静岡県', '22'],['愛知県', '23'],['三重県', '24'],
    ['滋賀県', '25'],['京都府', '26'],['大阪府', '27'],['兵庫県', '28'],['奈良県', '29'],['和歌山県', '30'],
    ['鳥取県', '31'],['島根県', '32'],['岡山県', '33'],['広島県', '34'],['山口県', '35'],['徳島県', '36'],
    ['香川県', '37'],['愛媛県', '38'],['高知県', '39'],['福島県', '40'],['佐賀県', '41'],['長崎県', '42'],
    ['熊本県', '43'],['大分県', '44'],['宮崎県', '45'],['鹿児島県', '46'],['沖縄県', '47']
  ]

  H_AREA_KBN = {
    '1' => '北海道', '2' => '青森県', '3' => '岩手県', '4' => '宮城県', '5' => '秋田県', '6' => '山形県',
    '7' => '福島県', '8' => '茨城県', '9' => '栃木県', '10' => '群馬県', '11' => '埼玉県', '12' => '千葉県',
    '13' => '東京都', '14' => '神奈川県', '15' => '新潟県', '16' => '富山県', '17' => '石川県', '18' => '福井県',
    '19' => '山科県', '20' => '長野県', '21' => '岐阜県', '22' => '静岡県', '23' => '愛知県', '24' => '三重県',
    '25' => '滋賀県', '26' => '京都府', '27' => '大阪府', '28' => '兵庫県', '29' => '奈良県', '30' => '和歌山県',
    '31' => '鳥取県', '32' => '島根県', '33' => '岡山県', '34' => '広島県', '35' => '山口県', '36' => '徳島県',
    '37' => '香川県', '38' => '愛媛県', '39' => '高知県', '40' => '福島県', '41' => '佐賀県', '42' => '長崎県',
    '43' => '熊本県', '44' => '大分県', '45' => '宮城県', '46' => '鹿児島県', '47' => '沖縄県'
  }

  SEX_KBN = {
    '1' => '男性',
    '2' => '女性'
  }

  INCOME_KBN = [
    ['100万円未満', '1'], ['100万円〜200万円未満', '2'], ['200万円〜300万円未満', '3'],
    ['300万円〜400万円未満', '4'], ['400万円〜500万円未満', '5'], ['500万円〜600万円未満', '6'],
    ['600万円〜700万円未満', '7'], ['700万円〜800万円未満', '8'], ['800万円〜900万円未満', '9'],
    ['900万円〜1000万円未満', '10'], ['1000万円以上', '11']
  ]

  H_INCOME_KBN = {
    '1' => '100万円未満',
    '2' => '100万円〜200万円未満',
    '3' => '200万円〜300万円未満',
    '4' => '300万円〜400万円未満',
    '5' => '400万円〜500万円未満',
    '6' => '500万円〜600万円未満',
    '7' => '600万円〜700万円未満',
    '8' => '700万円〜800万円未満',
    '9' => '800万円〜900万円未満',
    '10' => '900万円〜1000万円未満',
    '11' => '1000万円以上',
  }

  BUSINESS_KBN = [
    ['公務員', '1'], ['経営者・役員', '2'], ['会社員', '3'], ['自営業', '4'], ['自由業', '5'],
    ['専業主婦', '6'], ['パートアルバイト', '7'], ['学生', '8'], ['その他', '9']
  ]

  H_BUSINESS_KBN = {
    '1' => '公務員',
    '2' => '経営者・役員',
    '3' => '会社員',
    '4' => '自営業',
    '5' => '自由業',
    '6' => '専業主婦',
    '7' => 'パートアルバイト',
    '8' => '学生',
    '9' => 'その他',
  }

  EXP_MONTH = [
    ["01",1],["02",2],["03",3],["04",4],["05",5],["06",6],
    ["07",7],["08",8],["09",9],["10",10],["11",11],["12",12]
  ]

  EXP_YEAR = [
    ["19",2019],["20",2020],["21",2021],["22",2022],["23",2023],["24",2024],
    ["25",2025],["26",2026],["27",2027],["28",2028],["29",2029]
  ]

  H_CARD_BRAND = {
    'Visa' => 'visa.png',
    'JCB' => 'jcb.jpeg',
    'MasterCard' => 'master_card.png',
    'American Express' => 'american_express.jpeg',
    'Diners Club' => 'diners_club.png',
    'Discover' => 'discover.png'
  }

  # ログインユーザーのidを返す（return int）
  def user_id
    @user_id ||= session[:login]['user_id']
  end

  # ログインユーザーの性別を返す（return string）
  def user_sex_kbn
    @sex_kbn ||= session[:login]['sex_kbn']
  end

  # ログインユーザーの年齢認証フラグを返す（return boolean）
  def card_regist_flg(current_user)
    @card_regist_flg = current_user.card_regist_flg
  end

  # ログイン中であるか判定（ログイン中ならtrue）
  def login_flg
    if session[:login].present?
      return true
    end
    return false
  end

  # 現在ログイン中のユーザーを返す
  def current_user
    if session[:login]
      @current_user ||= User.find_by(id: session[:login]['user_id'])
    end
    return @current_user
  end

  # before_action：ユーザーがログイン中なら検索ページへ遷移
  def logged_in_user
    redirect_to search_path unless session[:login].nil?
  end

  # before_action：ユーザーがログアウト中ならトップページへ遷移
  def logged_out_user
    redirect_to root_path if session[:login].nil?
  end

  # before_action：年齢認証未実施ならリダイレクト
  def card_regist_check(current_user)
    return redirect_to new_card_path unless current_user.card_regist_flg
  end 

  # 初回メッセージ送信済みか判定
  # 9 9 以外のルームが存在するということは、どちらかが初回メッセージをすでに送っているということ
  def is_first_msg?(from_user_id, to_user_id, from_user_status='9', to_user_status='9')
    room = Room.get_room_info(from_user_id, to_user_id, from_user_status, to_user_status)
    if room.blank?
      return false
    end
    return true
  end

  # 日時を文字列でフォーマット変換
  def time_format(datetime)
    return datetime.strftime("%H:%M")
  end

  # 送信者をキーとして最新のメッセージを含むレコード一件取得
  def latest_message(from_user_id, room_id)
    event = Event.where(from_user_id: from_user_id, room_id: room_id, event_kbn: '12').order(created_at: 'DESC').limit(1)
    if event.blank?
      return []
    end
    return event + []
  end

  # 自分が入室していないルームidを取得（複数取得できた場合、バグ）
  # @param from_user_id ルーム作成者
  # @param to_user_id ルーム招待者（ログインユーザー）
  def room_id(from_user_id, to_user_id)
    room = Room.where(from_user_id: from_user_id, to_user_id: to_user_id, from_user_status: '1', to_user_status: '0')
    if room.blank?
      return []
    end
    room = room + []
    return room_id = room[0][:id]
  end

  # ペア状態か判定
  # @param from_user_id ログインユーザーのid
  # @param to_user_id 相手ユーザーのid
  def pair_flg(from_user_id, to_user_id)
    room = Room.where(from_user_id: [from_user_id, to_user_id])
               .where(to_user_id: [from_user_id, to_user_id])
               .where.not('from_user_status = ? and to_user_status = ?', '9', '9')
    if room.blank?
      return false
    end
    room.each {|r| room = r}
    fu_status = room.from_user_status
    tu_status = room.to_user_status
    p_fu_status = room.from_user_pair_status
    p_tu_status = room.to_user_pair_status
    if not fu_status == '1' && tu_status == '1' && p_fu_status == '2' && p_tu_status == '2'
      return false
    end
    return true
  end

  # 自分が送信したメッセージが未読か既読か判定（既読ならtrueを返す）
  # param flg 既読フラグ
  def read_flg(flg)
    if flg == true
      return true
    end
    return false
  end

  # トーク中のユーザーのルームidを返す
  # param from_user_id ログインユーザーのid
  # param to_user_id 相手ユーザーのid
  def talk_room_id(from_user_id, to_user_id)
    room = Room.where(from_user_id: [from_user_id, to_user_id])
               .where(to_user_id: [from_user_id, to_user_id])
               .where.not('from_user_status = ? and to_user_status = ?', '9', '9')
    if room.blank?
      return nil
    end
    return room.take.id
  end

  # トーク中のユーザーから、未読メッセージがあるか判定（未読メッセージがあるならtrueを返す）
  # param user_id ログインユーザーのid
  # param to_user_id トーク中の相手ユーザーのid
  def check_unread_message(user_id, to_user_id)
    room_id = talk_room_id(user_id, to_user_id)
    if room_id.blank?
      return false
    end
    receive_messages = Event.where(room_id: room_id, from_user_id: to_user_id, to_user_id: user_id, event_kbn: '12', read_flg: false)
    if receive_messages.blank?
      return false
    end
    return true
  end

  # 文字列をBase64エンコードする
  def encode(str)
    Base64.encode64(str)
  end

  # Base64エンコードされたものをデコードする
  def decode(str)
    Base64.decode64(str)
  end

  # 現在のパスを確認（headerのactiveクラス付与に使用）
  def check_current_path
    path = request.fullpath
    return 'search' if !!(path =~ /^\/search/)
    return 'mypage' if !!(path =~ /^\/mypage/)
    return 'index' if !!(path =~ /^\/room\/room_index/)
    return 'pair' if !!(path =~ /^\/room\/pair_info/)
    return false
  end
end
