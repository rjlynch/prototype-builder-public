class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # email_address and full_name are encrypted (see User). The email is
      # encrypted deterministically so it can still be looked up at sign in and
      # constrained by the unique index below; full_name is non-deterministic.
      t.string :email_address, null: false
      t.string :full_name, null: false

      # The team the user is currently working in (their "current team"). For a
      # new user this is their Personal Team.
      t.references :default_team, null: false, foreign_key: { to_table: :teams }

      t.timestamps
    end

    add_index :users, :email_address, unique: true
  end
end
