class AddTeamToWizards < ActiveRecord::Migration[8.1]
  # Nullable for now so existing wizards survive the migration; the backfill
  # assigns them a team and a later migration makes the column required.
  def change
    add_reference :wizards, :team, null: true, foreign_key: true
  end
end
