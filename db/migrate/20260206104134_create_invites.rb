class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :invites do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at
      t.datetime :claimed_at
      t.references :claimed_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :invites, :token, unique: true
  end
end
