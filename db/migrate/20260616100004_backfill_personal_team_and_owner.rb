class BackfillPersonalTeamAndOwner < ActiveRecord::Migration[8.1]
  # One-off bootstrap: before sign up exists, give the wizards already in the
  # database an owner. Creates a "Personal Team", a single user (Richard Lynch)
  # whose default team is that Personal Team, and assigns every team-less wizard
  # to it. Idempotent so it is safe to re-run and a no-op once applied.
  #
  # Uses the real application models because writing the encrypted email_address
  # needs the model's `encrypts` declaration.
  def up
    return if Wizard.where(team_id: nil).none? && User.exists?(email_address: "rjlynchdev@gmail.com")

    team = Team.find_or_create_by!(name: "Personal Team")

    user = User.find_or_initialize_by(email_address: "rjlynchdev@gmail.com")
    user.full_name ||= "Richard Lynch"
    user.default_team = team
    user.save!

    Membership.find_or_create_by!(user: user, team: team)

    Wizard.where(team_id: nil).update_all(team_id: team.id)
  end

  def down
    # Irreversible bootstrap data; leave the records in place.
    raise ActiveRecord::IrreversibleMigration
  end
end
