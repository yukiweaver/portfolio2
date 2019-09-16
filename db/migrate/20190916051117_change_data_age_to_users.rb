class ChangeDataAgeToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :age, :string
  end
end
