class AddCardRegistFlgToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :card_regist_flg, :boolean, default: false
  end
end
