class CreateFriendships < ActiveRecord::Migration[8.1]
  def change
    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.integer :current_streak, null: false, default: 0
      t.integer :longest_streak, null: false, default: 0
      t.date :streak_date
      t.boolean :user_hooted_today, null: false, default: false
      t.boolean :friend_hooted_today, null: false, default: false

      t.timestamps
    end

    add_index :friendships, [ :user_id, :friend_id ], unique: true
  end
end
