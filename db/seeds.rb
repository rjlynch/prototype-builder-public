# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# What this seeds (development only): a ready-to-use account for a new developer
# joining the project, plus a copy of the "EYTRP" wizard so they have a real,
# fully-built journey to log in and start editing straight away.
#
#   - User test@example.com, in its own Personal Team (mirrors a normal signup).
#   - The "EYTRP" wizard, owned by that team, rebuilt from the committed fixture
#     at db/seeds/eytrp_wizard.json.
#
# Sign in is via magic link, so there's no password. To get in, request a link
# at /sign_in for test@example.com; in development the email is printed to the
# Rails server console (config.action_mailer.delivery_method = :console), so
# copy the magic link from there to finish signing in.
#
# Running this more than once is safe: the user is found-or-created, and the
# wizard is rebuilt from scratch each run (destroyed if present, then recreated)
# so re-seeding always yields the pristine journey, never duplicates.

unless Rails.env.development?
  Rails.logger.info "Skipping development seeds in #{Rails.env}"
  return
end

SEED_USER_EMAIL = "test@example.com"
SEED_USER_NAME = "Test Developer"
WIZARD_FIXTURE = Rails.root.join("db/seeds/eytrp_wizard.json")

ActiveRecord::Base.transaction do
  # A normal account looks like: a Personal Team, the user, and their membership
  # of it (see Signup#activate!). Recreate that shape so the seeded user behaves
  # exactly like one that signed up through the app.
  user = User.find_by(email_address: SEED_USER_EMAIL)

  unless user
    team = Team.create!(name: "Personal Team")
    user = User.create!(email_address: SEED_USER_EMAIL, full_name: SEED_USER_NAME, default_team: team)
    Membership.create!(user: user, team: team)
    puts "Created user #{SEED_USER_EMAIL} in team ##{team.id}"
  end

  team = user.default_team

  # Rebuild the wizard from the fixture each run so seeding is idempotent and
  # always produces the pristine journey. Destroying cascades to its pages,
  # components, branch rules and conditions.
  data = JSON.parse(WIZARD_FIXTURE.read)

  team.wizards.where(name: data["name"]).destroy_all

  wizard = team.wizards.create!(name: data["name"])

  data["pages"].each do |page_attrs|
    components = page_attrs.delete("components")
    page = wizard.pages.create!(page_attrs)

    components.each do |component_attrs|
      branch_rules = component_attrs.delete("branch_rules")
      component = page.components.create!(component_attrs)

      branch_rules.each do |rule_attrs|
        conditions = rule_attrs.delete("conditions")
        rule = component.branch_rules.create!(rule_attrs)
        conditions.each { |condition_attrs| rule.conditions.create!(condition_attrs) }
      end
    end
  end

  puts "Seeded wizard #{data["name"].inspect} (#{wizard.pages.count} pages) for #{SEED_USER_EMAIL}"
end
