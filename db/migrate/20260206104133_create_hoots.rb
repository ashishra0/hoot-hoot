class CreateHoots < ActiveRecord::Migration[8.1]
  def change
    create_table :hoots do |t|
      t.references :sender,     null: false, foreign_key: { to_table: :users }
      t.references :receiver,   null: false, foreign_key: { to_table: :users }
      t.references :friendship, null: false, foreign_key: true

      t.datetime :created_at, null: false
    end

    add_index :hoots, [ :sender_id, :receiver_id, :created_at ]
  end
end
