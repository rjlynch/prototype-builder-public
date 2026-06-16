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

## Deployment

Deployed with [Kamal](https://kamal-deploy.org) to a Hetzner host
(`wizard.lynchsoftware.com`), sharing a kamal-proxy with other apps on the
box. The image is built and pushed to GitHub Container Registry (`ghcr.io`).

**Continuous deployment.** Every push to `main` (a direct push or a merged
PR) triggers `.github/workflows/deploy.yml`, which builds the image and runs
`kamal deploy`. Production sits behind HTTP Basic auth (the `basic_auth`
key in Rails encrypted credentials) while it's open to invited testers; the
`/up` health check is exempt.

One-time setup — add two repository secrets (Settings → Secrets → Actions):

- `RAILS_MASTER_KEY` — contents of `config/master.key`.
- `SSH_PRIVATE_KEY` — a private key whose public half is in the server's
  `root` `authorized_keys`.

The registry uses the workflow's `GITHUB_TOKEN` (no PAT needed).

**Manual operations** (run locally; needs SSH access and the gh CLI logged
in for the registry token):

```sh
bin/kamal deploy     # build + deploy by hand
bin/kamal console    # Rails console on the server
bin/kamal shell      # bash shell in the container
bin/kamal logs       # tail application logs
bin/kamal db         # sqlite dbconsole
bin/db-backup        # stream a production DB snapshot to tmp/backups/
```
