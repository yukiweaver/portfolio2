class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :room, index: true, foreign_key: true
      t.references :from_user
      t.references :to_user
      t.string :event_kbn
      t.text :data

      t.timestamps
    end
    add_foreign_key :events, :users, column: :from_user_id
    add_foreign_key :events, :users, column: :to_user_id
  end
end
