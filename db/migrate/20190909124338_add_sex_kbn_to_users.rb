class AddSexKbnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sex_kbn, :string
  end
end
