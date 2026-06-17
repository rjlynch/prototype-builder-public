class CreateSignups < ActiveRecord::Migration[8.1]
  # A pending sign up: the full name + email someone entered, held until they
  # confirm it via a magic link (which creates the real Team + User) or it is
  # cleaned up after 15 minutes. Both columns are encrypted PII, like User.
  def change
    create_table :signups do |t|
      t.string :email_address, null: false
      t.string :full_name, null: false

      t.timestamps
    end
  end
end
