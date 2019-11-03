class Card < ApplicationRecord
  belongs_to :user

  def self.card_data(user_id, customer_id, card_id)
    Card.new(user_id: user_id, customer_id: customer_id, card_id: card_id)
  end
end
