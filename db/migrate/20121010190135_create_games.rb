class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :owner_id
      t.datetime :start_time
      t.string :state

      t.timestamps
    end

    add_index :games, :owner_id
  end
end
