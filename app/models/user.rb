class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :sex_kbn, presence: true
  validates :area_kbn, presence: true
  validates :age, presence: true
  validates :profile, length: { maximum: 255 }
  validates :free_entry, length: { maximum: 255 }
  validate :check_sex_kbn, :check_area_kbn, :check_age, :check_business_kbn, :check_income_kbn
  mount_uploader :image, ImageUploader

  # エリアで検索（ページネーション：10人ずつ）
  def self.search(sex_kbn, user_id, page, search)
    if sex_kbn == '1'
      if search.present?
        User.paginate(page: page, per_page: 10).where('sex_kbn = ? and area_kbn = ?', '2', search).where.not(id: user_id)
      else
        User.paginate(page: page, per_page: 10).where(sex_kbn: '2').where.not(id: user_id)
      end
    elsif sex_kbn == '2'
      if search.present?
        User.paginate(page: page, per_page: 10).where('sex_kbn = ? and area_kbn = ?', '1', search).where.not(id: user_id)
      else
        User.paginate(page: page, per_page: 10).where(sex_kbn: '1').where.not(id: user_id)
      end
    end
  end

  # カスタムメソッド

  # 性別
  def check_sex_kbn
    arr_sex_kbn = ['1', '2']
    errors.add(:sex_kbn, ": 性別が不正な値です。") unless arr_sex_kbn.include?(sex_kbn)
  end

  # 居住地
  def check_area_kbn
    arr_area_kbn = [*('1'..'47')]
    errors.add(:area_kbn, ": 居住地が不正な値です。") unless arr_area_kbn.include?(area_kbn)
  end

  # 年齢
  def check_age
    arr_age = [*('18'..'100')]
    errors.add(:age, ": 年齢が不正な値です。") unless arr_age.include?(age)
  end

  # 職業：空はOK
  def check_business_kbn
    arr_business_kbn = [*('1'..'9')]
    if !business_kbn.empty?
      errors.add(:business_kbn, ": 職業が不正な値です。") unless arr_business_kbn.include?(business_kbn)
    end
  end

  # 年収：空はOK
  def check_income_kbn
    arr_income_kbn = [*('1'..'11')]
    if !income_kbn.empty?
      errors.add(:income_kbn, ": 年収が不正な値です。") unless arr_income_kbn.include?(income_kbn)
    end
  end
end
