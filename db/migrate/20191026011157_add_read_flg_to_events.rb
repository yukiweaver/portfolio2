class AddReadFlgToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :read_flg, :boolean, default: false
  end
end
