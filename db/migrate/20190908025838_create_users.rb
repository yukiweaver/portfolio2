class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :profile
      t.integer :age
      t.string :income_kbn
      t.string :business_kbn
      t.string :area_kbn
      t.string :free_entry

      t.timestamps
    end
  end
end
