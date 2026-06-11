# GOV.UK Prototype Builder

A web UI that lets non-technical civil servants (policy staff, interaction
designers) prototype GOV.UK journeys — no prototype kit, no code, no hosting
to sort out — and share links to what they build for feedback.

The builder is a two-pane editor: controls on the left, a live interactive
preview on the right. Journeys ("wizards") are sequences of pages made of
components (paragraphs, inputs, continue buttons).

See [PLAN.md](PLAN.md) for the data model, route map, style rules, progress
log, and open decisions.

## Stack

Ruby on Rails 8.1 with standard conventions throughout: SQLite,
Solid Queue/Cache/Cable, Hotwire (Turbo + Stimulus), Propshaft, importmap.
GOV.UK styling via vendored [govuk-frontend](vendor/README.md) v6.2.0.

## Getting started

```sh
bin/setup            # installs gems, prepares the database
bin/rails server     # http://localhost:3000
```

## Tests

RSpec + Capybara. `:js`-tagged system specs run in headless Chrome (Chrome
must be installed; Selenium manages the driver).

```sh
bundle exec rspec    # full suite
bin/rubocop          # style (rubocop-rails-omakase)
bin/brakeman         # security static analysis
```

The end-to-end journey from the project brief lives in
`spec/system/building_a_wizard_spec.rb`.
