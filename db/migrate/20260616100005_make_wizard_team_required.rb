class MakeWizardTeamRequired < ActiveRecord::Migration[8.1]
  # After the backfill every wizard has a team, so enforce it at the database.
  def change
    change_column_null :wizards, :team_id, false
  end
end
