class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
  validates :sex_kbn, presence: true
  validates :area_kbn, presence: true
  validates :age, presence: true

  # エリアで検索
  def self.search(sex_kbn, user_id,  search)
    if sex_kbn == '1'
      if search.present?
        User.where('sex_kbn = ? and area_kbn = ?', '2', search).where.not(id: user_id)
      else
        User.where(sex_kbn: '2').where.not(id: user_id)
      end
    elsif sex_kbn == '2'
      if search.present?
        User.where('sex_kbn = ? and area_kbn = ?', '1', search).where.not(id: user_id)
      else
        User.where(sex_kbn: '1').where.not(id: user_id)
      end
    end
  end
end
