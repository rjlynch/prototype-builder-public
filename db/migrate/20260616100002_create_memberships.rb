class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    # A user belongs to a team at most once; the join row models multi-team
    # membership.
    add_index :memberships, %i[user_id team_id], unique: true
  end
end
