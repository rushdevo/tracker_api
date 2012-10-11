class CreateUserGames < ActiveRecord::Migration
  def change
    create_table :user_games do |t|
      t.integer :user_id
      t.integer :game_id

      t.timestamps
    end

    add_index :user_games, :user_id
    add_index :user_games, :game_id
  end
end
