class CreateRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :rooms do |t|
      t.string :from_user_status, default: '1'
      t.string :to_user_status, default: '0'
      t.datetime :exit_date, default: '9999/12/31'
      t.datetime :close_date, default: '9999/12/31'
      t.string :from_user_pair_status, default: '0'
      t.string :to_user_pair_status, default: '0'
      
      t.references :from_user, foreign_key: { to_table: :users }, null: false
      t.references :to_user, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
  end
end
