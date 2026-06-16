class AddSignInTrackingToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_signed_in_at, :datetime
    add_column :users, :sign_in_count, :integer, default: 0, null: false
  end
end
