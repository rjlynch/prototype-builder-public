# GOV.UK Prototype Builder — Plan & Progress Log

A web UI that lets non-technical civil servants (policy staff, interaction
designers) prototype GOV.UK journeys without the prototype kit, and share
links to what they build. See the project brief in the README / original
conversation.

## Style rules (enforced throughout)

* RESTful routes only
* Locals to all views, no instance variables; ideally one local per view
* Form objects back create / update / destroy pages
* No service objects — jobs with `perform_now` instead
* No model callbacks
* Validations at both form and model level (duplication is fine)
* Hotwire first; Stimulus JS rather than plain JS
* No domain concepts in JavaScript, CSS, or helpers (must be extractable to
  a library)
* Simplest approach possible

## Data model

```
Team              an account; owns wizards, has many users via memberships
  name            string ("Personal Team" for a single user)

User              a person who signs in to build wizards
  email_address   encrypted (deterministic + downcase so it stays queryable
                  and uniquely indexed); PII
  full_name       encrypted (non-deterministic); PII
  default_team_id  the team the user is currently working in

Membership        joins a user to a team (the grant of access); a user can
  user_id         belong to several teams
  team_id         unique on [user_id, team_id]

Wizard            the prototype/journey being built
  team_id         the owning team
  name            string (defaults to first page title later; MVP: "Untitled wizard")

Page              one screen in the journey, ordered
  wizard_id
  position        integer, 1-based, unique within wizard
  title           string  (the page H1 — always present in the builder)
  slug            string, unique within wizard; tracks the title
                  ("What is your name" -> what-is-your-name) until the user
                  customises it; defaults to page-N while untitled
  panel_style     "none" (default) | "success" (green, centred) |
                  "information" (blue, left-aligned) — GOV.UK panel holding
                  the H1 (and any in_panel copy) at the top of the page

Component         one element on a page, ordered
  page_id
  position        integer, 1-based, unique within page
  kind            string enum: "paragraph" | "subheading" | "list" |
                  "text_input" | "radios" | "button"
  text            paragraph body / subheading / button label / list items
                  (lists: one item per line)
  name            inputs: question name; required, generated unique per
                  wizard (question-N); parameterised form = "input key"
  label           inputs: visible label (radios: fieldset legend)
  hint            inputs: hint text
  options         radios: one option per line; submitted value is the
                  parameterised option label
  list_style      lists: "none" | "bullet" | "number" (GOV.UK list styles)
  list_spaced     lists: extra spacing between items
  button_style    buttons: "continue" (default) | "secondary" | "inverse" |
                  "start" | "warning" (GOV.UK button variants)
  target_slug     buttons: page slug to go to as the "else" when no branch rule
                  matches; blank continues linearly to the next page
  in_panel        paragraphs/subheadings: render inside the page's panel body
                  (only meaningful while the page has a panel_style set)

BranchRule        one "if answer X is Y go to page Z" condition on a button
  component_id    the button
  position        evaluation order, first complete match wins
  input_name      any input key in the wizard (cross-page branching works)
  value           matched forgivingly: both sides parameterised
  target_slug     page slug; in builder mode a missing target is created
                  blank when the button is clicked
```

Flat columns on `components` rather than STI/delegated types/JSON — simplest
thing that works for these kinds. Revisit if kinds multiply.

Navigation: clicking a button POSTs the preview/run form to
`pages/:id/answers`. Answers are stored in the session (per wizard, keyed by
input key). The clicked button's first matching branch rule decides the next
page; failing that the button's own `target_slug` ("go to page"); failing that
the journey continues linearly by position (creating the destination page in
builder mode if needed).

## Routes (RESTful only)

```
root                         landings#show (landing page)
resource  :sign_in           new (email form), create (email a magic link,
                             then redirect), show ("check your email")
resource  :session           new (magic-link confirm page), create (consume
                             token + sign in), destroy (sign out)
resources :wizards           index (dashboard), create, show (run/share mode)
resources :pages             edit (THE BUILDER), update, show (run mode)
  resources :components      create
  resource  :answers         create (continue click: store answers, branch, redirect)
resources :components        update, destroy
  resources :branch_rules    create
resources :branch_rules      update, destroy
```

* `pages#edit` is the two-pane builder: left = controls, right = live preview.
* `pages#show` is run mode (used by share links; the preview pane reuses the
  same partial).
* Live preview updates: every builder field is a small form that auto-submits
  (generic Stimulus `autosubmit` controller, debounced) as a turbo-stream
  PATCH; the response replaces the preview pane.

## Form objects

* `WizardForm`        — create wizard (+ its first blank page)
* `PageForm`          — update title/slug (slug derivation lives here)
* `AddComponentForm`  — append component with per-kind defaults + generated name
* `ComponentForm`     — update components (kind-aware validation)
* `MoveComponentForm` — swap a component up/down with its adjacent sibling
                        (by order, so it works across position gaps)
* `AddBranchRuleForm` — append blank rule to a button
* `BranchRuleForm`    — update a rule (parameterises the target slug)
* `ContinueForm`      — resolve a button click to the next page (branch or
                        linear; creates missing destinations in builder mode)

## Delivery steps

- [x] 0. Commit generated Rails app
- [x] 1. This plan
- [x] 2. RSpec + Capybara (+ selenium headless Chrome) setup
- [x] 3. Vendor govuk-frontend CSS/JS/assets (MVP: used as-is)
- [x] 4. Landing page + stubbed sign in
- [x] 5. Wizard + Page models; "New wizard" lands on builder with blank page
- [x] 6. Title field with live preview (autosubmit + turbo stream)
- [x] 7. Paragraph components: add, edit, remove — live preview
- [x] 8. Continue button component: add, rename, click-through to next page
- [x] 9. Text input component (text kind first), interactive in preview
- [x] 10. Full journey feature spec mirroring the rough spec in the brief
- [x] 11. Run mode / share link (wizards#show walks the journey)

### Phase 2: branching (2026-06-11)

- [x] 12. Page slugs (derive from title until customised, unique per wizard)
- [x] 13. Radios component + generated unique input names (question-N)
- [x] 14. Answers in session + BranchRule on buttons + ContinueForm; preview
      and run mode submit one answers form; brief's eligibility scenario
      passes in builder and run mode

### Phase 3: UX tightening (2026-06-11)

Reviewed by walking the app in headless Chrome with screenshots
(tmp/ux-review/). High-impact fixes, one commit each:

- [x] Sticky preview pane (was scrolling out of view on long builders)
- [x] GOV.UK logotype white (was v5 markup -> blue-on-blue in v6)
- [x] Run layout for shared prototypes: plain header + "Prototype" phase
      banner, no builder chrome
- [x] Builder heading = page title; slug only in its field; pages nav
      streamed fresh on title/slug updates (was three stale-able copies)
- [x] Wizards renameable from the builder (autosubmit, 204 on stream)

Deferred from the review (medium/polish): page delete + reorder, input
labels alongside question-N in rule selects, save indicator, empty-state
hints, flattening the "Add input" disclosure, run-mode dead-end message,
copy-share-link button, radios legend-vs-title hint, "Button" card
heading wording.

2026-06-12 — all deferred items above, plus a second round of user
feedback (pane padding/background/full-height, wizard settings page,
H1-as-label option, collapsible editor cards, subheading component,
vertical add-button stack), filed as GitHub issues #3–#16 on
rjlynch/prototype-builder, each labelled low/medium/high difficulty.
The backlog now lives in the issue tracker, not this file.

## Progress log

* 2026-06-11 — Project start. Committed generated Rails 8.1 app. Wrote plan.
* 2026-06-11 — Steps 2–4 done. RSpec + Capybara (`:js` → headless Chrome)
  running. govuk-frontend v6.2.0 vendored (CSS via Propshaft, ESM JS via
  importmap, fonts/images under public/assets because the dist CSS hardcodes
  those paths — see vendor/README.md; note v6 uses the refreshed brand
  green #0f7a52). GOV.UK layout (header, service nav, footer), landing page,
  stubbed sign in/out (session flag), empty dashboard. 4 specs green.
* 2026-06-11 — Steps 5–6 done. Wizard/Page models (no callbacks; position
  set by form objects). WizardForm creates wizard + blank first page;
  "New wizard" lands on the builder (pages#edit, app-split-pane layout).
  PageForm backs the title field; generic `autosubmit` Stimulus controller
  debounce-submits as a turbo stream that replaces the preview pane.
  NextPageForm ready for the continue button. 12 specs green.
* 2026-06-11 — Steps 7–10 done. Component model (flat columns, kind enum)
  with AddComponentForm (per-kind defaults, appends at end) and
  ComponentForm (one class backs all editor forms). Builder pane: editor
  card per component with Remove; Add paragraph / Add continue button
  buttons; "Add input" disclosure with Text input (more types later).
  Turbo-stream strategy: create/destroy replace builder+preview panes,
  update replaces preview only (typing focus never stolen). Preview's
  continue button POSTs to pages#create (find-or-create next page) in
  builder mode. Full journey spec from the brief passes. 14 specs green.
* 2026-06-11 — Step 11 done, MVP complete. Run mode: wizards#show (the
  share link, no sign-in required) redirects to the first page's
  pages#show, which renders the same preview partial with mode: :run —
  continue buttons link to the next page, disabled on the last page.
  "Share this wizard" link on the builder. 16 specs green, rubocop and
  brakeman clean. README rewritten.
* 2026-06-11 — Phase 2 (branching) done in three slices. (1) Page slugs:
  derive-from-title-until-customised via PageForm, title and slug as
  separate autosubmit forms, slug heading + pages nav in the builder.
  (2) Radios kind + options column; inputs require a name, generated
  unique per wizard (question-N). (3) Branching: preview/run render one
  answers form posting to pages/:id/answers; AnswersController stores
  session answers per wizard and ContinueForm resolves the clicked
  button's BranchRules (first complete match, parameterised comparison,
  cross-page answers supported) with linear fallback; builder mode
  creates missing destinations (branch targets land at end of journey).
  Branch rule editor on button cards (select input / value / target
  slug) with rule annotations under the preview button. Eligibility
  scenario from the brief passes in builder and run mode. 34 specs
  green; rubocop + brakeman clean. NOTE: Capybara.automatic_label_click
  is on because GOV.UK radios visually hide the input element.
* 2026-06-11 — Phase 3 (UX): screenshot-driven review, then fixed the
  five high-impact findings (see Phase 3 section). Wizard name is now
  editable in the builder; run mode looks like a GOV.UK service with a
  Prototype phase banner; preview is sticky. 36 specs green.

* 2026-06-12 — Issue #16: editor cards are collapsible <details> elements.
  A generic `persisted-details` Stimulus controller remembers open/closed
  state in sessionStorage keyed by element id, so it survives the full
  builder-pane turbo-stream replaces (and reloads). Cards default open;
  collapsed cards show kind + a content snippet (label for inputs, text
  otherwise), kept fresh client-side by a generic `mirror` Stimulus
  controller copying the field's value into the summary as you type —
  no extra server streams. Remove moved out of the clickable summary
  into an actions row. 37 specs green.

* 2026-06-12 — Issue #15: inputs can use the page title as their label
  (text input) or fieldset legend (radios) — the GOV.UK single-question
  pattern. New title_as_label boolean on components with a checkbox in
  both input editors; only one input per page may take it (validated at
  form and model level), the redundant Label field hides while it is
  on, and other inputs stop offering the option. The builder pane
  re-renders on toggle (a checkbox click is not typing) so the editors
  reshape immediately; the preview's plain H1 steps aside when a
  heading component exists. Same partial serves run mode. 43 specs
  green.

* 2026-06-12 — Issues #3 and #4: pages can be deleted and reordered.
  "Delete this page" (Turbo confirm) under the pages nav; DeletePageForm
  keeps at least one page per wizard, renumbers survivors contiguously
  (walking down in position order to dodge the unique index), and lands
  the user on the previous page. Up/down arrows in the pages nav swap
  positions via a nested singular position resource + MovePageForm
  (swap parks at max+1 first, same index reason); slugs are untouched
  so branch rules survive reordering. 53 specs green.

* 2026-06-12 — Issue #14: wizard settings moved off the builder onto
  their own page (wizards#edit, autosubmit name field whose h1 streams
  back the save as feedback). The builder shows the wizard name as a
  caption over the page heading and links to settings beside the share
  link. 53 specs green.

* 2026-06-13 — Fixed editor focus jumping between same-kind cards. Root
  cause: ComponentForm-backed editor forms generated duplicate field ids
  (every paragraph editor was `component_text`), so after an autosubmit
  Turbo restored focus by id and landed on the first match. Fixed by
  namespacing the editor form with `dom_id(component)`, which scopes every
  field id and label `for` per component (dropped the now-redundant manual
  id/for on the title_as_label checkbox). New :js spec records any focusin
  bounce to another textarea. Considered Turbo morph: it would still need
  unique ids and isn't required once ids are unique. 59 specs green.

* 2026-06-13 — Page heading options (GOV.UK heading styles). Added
  `heading_size` (xl/l/m/s, default l) and `caption` columns to pages,
  wired through PageForm's submitted-flag pattern. The title section gets a
  "Heading size" select; the caption lives in its own disclosure (like the
  slug). Page#heading_class / #caption_class derive the classes (caption "s"
  reuses -m since GOV.UK has no caption-s). Size + caption apply across all
  three H1 render paths — plain heading, and the title_as_label input
  label/legend — via a shared pages/_preview_caption partial. 60 specs green.

* 2026-06-14 — Builder UI reorganisation. The wizard name moved out of the
  builder body and into the service navigation: pages#edit sets a
  content_for(:service_navigation_context) the shared service-nav partial
  yields after the service name, linking back to wizard settings (removed
  the pages/_page_heading partial and its turbo-stream). The pages nav moved
  off the wizard settings page back onto the builder, rendered as GOV.UK tabs
  (current page = selected tab) showing the truncated page name (title, or
  slug while untitled) with the reorder arrows riding inside each tab —
  raised above the tab's full-bleed ::after overlay via z-index so they stay
  clickable. Drag-to-reorder will replace the arrows later. 60 specs green;
  rubocop clean. Follow-ups: tab labels truncate to the first 5 characters;
  the redundant next-page link by the title was dropped (previous-page stays).

* 2026-06-14 — Insert pages from the tabs. Each tab gets a plus icon that
  inserts a new blank page right after that tab's page and lands the user on
  it. RESTful: nested `resource :successor` under pages → SuccessorsController,
  backed by InsertPageForm, which bumps the trailing pages' positions down by
  one (highest first, to dodge the unique [wizard_id, position] index) and
  gives the new page a unique position-based slug; existing slugs are untouched
  so branch rules survive. 64 specs green; rubocop clean.

* 2026-06-14 — Page title section folded into a collapsible app-card, like the
  component editors (its own pages/_title_card partial: title + heading size +
  caption + slug, with a live-mirrored title snippet). Dropped the section
  divider; the caption left its disclosure to sit always-visible before the
  slug (which keeps its disclosure). Removed the now-dead app-field-heading /
  app-section-divider CSS; app-card__actions became a flex row (Previous-page
  link + Remove). System specs that assumed the first .app-card was a component
  were retargeted, and the add_component helper now waits for the (always
  present) title card before counting, removing a mid-render race. 64 green.

* 2026-06-14 — Reorder editor cards. Up/down arrows ride in a column beside
  each component editor (a new `.app-editor` flex wrapper; arrows are siblings
  of the `<details>`, not inside its `<summary>`, so they show whether the
  card is open or closed and a click never toggles the card). The arrow PATCHes
  `component_position_path` → `ComponentPositionsController#update` →
  `MoveComponentForm`, which swaps positions with the adjacent sibling (by
  order, surviving the gaps that component deletes leave behind). Both panes
  re-render via the existing `RendersBuilderPanes` turbo streams. Gotcha worth
  remembering: the form loads `page.components` (caching the association) before
  swapping, so the controller must `reload` it or the re-rendered panes show the
  old order — the pages reorder dodged this only because it `redirect_back`s.

* 2026-06-15 — Issue #38: back links. A GOV.UK back link renders at the top of
  every page after the first, in both run mode and the builder preview (shared
  pages/_back_link partial inside the preview's width container). It is a
  singular per-page nav element, so — like heading_size/caption — it lives as a
  Page attribute (`back_link` boolean, default true) wired through PageForm, not
  as a Component. The journey isn't linear (branch rules can skip pages), so the
  "go to the previous page" default can't be resolved server-side; instead the
  link returns through browser history via a generic `back-link` Stimulus
  controller (history.back()), so the anchor carries only a placeholder `#`
  href and the partial needs no mode/builder context. A per-page checkbox in the
  title card turns it off (shown only when the page has a previous one). Dropped
  the issue's "configurable target slug": with history.back() the default already
  lands on the real previous page, and a free-text slug is a technical concept
  that would confuse the non-technical audience and let them create dead links.
  Review follow-up: PageForm switched to `ActiveModel::Attributes` +
  `initialize(page, params:)` that reverse-merges the page's current values, so
  unsubmitted fields re-save as no-ops and the per-attribute `_submitted` flags
  are gone — only the slug-tracks-title rule still inspects which fields were
  submitted (a single `@submitted` hash). 82 specs green; rubocop + brakeman
  clean.

* 2026-06-15 — Issue #39: lists. Added a `list` editor component (separate from
  paragraphs) offering the GOV.UK list styles. It rides the existing Component
  mechanism rather than a bespoke model: items live in the shared `text` column
  (one per line, parsed by `list_items`, mirroring radios' `option_list`), and
  two new columns hold the presentation — `list_style` (none/bullet/number,
  validated against `Component::LIST_STYLES`) and a `list_spaced` boolean for
  extra spacing between items. The preview composes the GOV.UK classes
  (`govuk-list` + `--bullet`/`--number`/`--spaced`) and renders `<ol>` for
  numbers, `<ul>` otherwise, all in the partial so no CSS knowledge leaks into
  the model. Editor adds a textarea + a small radio group for style + a spacing
  checkbox, all autosubmitting like the other editors; ComponentForm/permit gained
  the two fields. 87 specs green (new model, form and system specs); rubocop +
  brakeman clean.

* 2026-06-15 — Issue #52: brought the other page form objects onto PageForm's
  call shape, so `page` is the first positional arg everywhere. DeletePageForm
  and InsertPageForm take no params (`new(page)`); MovePageForm takes
  `new(page, params: { position: })` and adopts `ActiveModel::Attributes`
  (`attribute :position, :integer`), dropping the manual `position.to_i`.
  Behaviour unchanged. 82 specs green; rubocop clean.

* 2026-06-16 — Issue #36: bold + links in paragraphs and lists. After a first
  attempt with Trix/Action Text (PR #55) proved too heavy for a feature where
  "we're not entering loads of links", the scope was reset to a tiny markdown
  subset rendered at display time — `**bold**` and `[text](target)` — so no
  WYSIWYG editor, no Action Text/Active Storage, no migration: content stays in
  the existing `text` column. A `govuk_markdown` helper HTML-escapes the source
  first, then introduces only `<strong class="govuk-!-font-weight-bold">` and
  `<a class="govuk-link">`, so user input can't inject markup (brakeman clean on
  the html_safe output). Link targets resolve forgivingly: full URLs / `mailto:`
  / root-relative / `#heading` anchors pass through; anything else is looked up
  as a sibling page slug and linked to that page, or left as an inert `#` (which
  also neutralises `javascript:` schemes). Subheadings gained an `id` (the
  parameterised text) so same-page heading links work. Both the paragraph and
  list editors keep their plain textarea and gain a shared "Help with
  formatting" `app-disclosure` explaining the syntax. Syntax-highlighting the
  textarea was left out (explicitly a nice-to-have, and the overlay technique it
  needs was the kind of complexity that sank the Trix attempt). 96 specs green
  (helper + system); rubocop + brakeman clean. Follow-ups: a page/heading link
  picker, and textarea link highlighting.
* 2026-06-16 — Deploy to Hetzner (issue #30). Kamal 2 deploy to the existing
  `77.42.86.45` host (shared kamal-proxy with workout_tracker), TLS on
  `wizard.lynchsoftware.com`. Switched the registry from the reference app's
  server-local `localhost:5555` to `ghcr.io` so a GitHub runner can push —
  CD (`.github/workflows/deploy.yml`) builds and `kamal deploy`s on every push
  to main (covers both "push" and "merged PR" triggers). Production turns on
  `assume_ssl`/`force_ssl` (with `/up` excluded). The whole app sits behind
  HTTP Basic auth in production only (ApplicationController `before_action`,
  creds in Rails encrypted credentials under `basic_auth`) while it's open to
  invited testers; `/up` bypasses it as Rails::HealthController doesn't inherit
  ApplicationController. Aliases `console`/`shell`/`logs`/`db`; `bin/db-backup`
  streams a consistent sqlite snapshot to `tmp/backups`. One-time manual setup
  (GitHub secrets `RAILS_MASTER_KEY` + `SSH_PRIVATE_KEY`) documented in README.
  96 specs green; rubocop clean; production boot/eager-load verified.
* 2026-06-16 — Issue #58: email provider. Resend (`resend` gem) is the
  production mailer — `config.action_mailer.delivery_method = :resend` in
  production.rb, with the API key read from encrypted credentials
  (`resend.api_key`) in a `config/initializers/resend.rb`; the gem's railtie
  registers the `:resend` delivery method. Production also flips
  `raise_delivery_errors = true` so a broken setup surfaces rather than dropping
  mail. Development prints emails to the console instead: a tiny
  `ConsoleMailDelivery` (registered as `:console` via `add_delivery_method`)
  writes the full message to `$stdout` and the log, so testers see mail in the
  server output with no inbox or external call. `ApplicationMailer`'s default
  `from` moved off the generated `from@example.com` to
  `noreply@wizard.lynchsoftware.com` (the domain verified with Resend — DNS
  TXT/MX configured on Cloudflare; will need redoing on a future domain). 99
  specs green; rubocop + brakeman clean; dev/prod mailer resolution verified.
* 2026-06-16 — Issue #32 (accounts), PR 1 of 3: account model + authorization,
  no sign in yet. New `Team` (the account), `User` (email_address + full_name,
  both encrypted at rest — email deterministic + downcase so it stays
  queryable/uniquely indexed for the magic-link lookup later, full_name
  non-deterministic), and a `Membership` join so a user can belong to several
  teams. A user's `default_team` is the team they're "currently" working in.
  `Wizard` now `belongs_to :team` (backfilled, then NOT NULL). Authorization is
  Pundit and hangs off **team membership**: `WizardPolicy`/`PagePolicy` allow
  edit/update for any record owned by a team the user belongs to, and
  `WizardPolicy::Scope` returns wizards across all the user's teams. "Current
  team" is kept out of the policies as a navigation concern: the dashboard
  (`wizards#index`) layers a `where(team: current_team)` filter on top of the
  membership scope, and new wizards are created in `current_team`. The public
  share/run views (`wizards#show`, `pages#show`) stay unauthenticated. The current user is **hardcoded** in
  ApplicationController (`rjlynchdev@gmail.com`) until PR 2 adds magic-link sign
  in; PR 3 adds sign up. A one-off, idempotent data migration created the
  "Personal Team" + Richard Lynch user and assigned the existing wizards to it
  (runs automatically on the next prod deploy). Active Record Encryption keys
  added to credentials (`active_record_encryption`). 121 specs green; rubocop +
  brakeman clean.
* 2026-06-16 — Issue #32 (accounts), PR 2 of 3: magic-link sign in; the
  hardcoded current user is gone. `current_user` now comes from
  `session[:user_id]` (set by `sign_in`, which resets the session first to
  avoid fixation). Flow: `sign_ins#new` is an email form → `sign_ins#create`
  emails a link to an existing user (or a plain "no account yet" note to an
  unknown address) and redirects to `sign_ins#show`, the same neutral "check
  your email" page either way, so it never reveals who is registered. (Redirect,
  not render: Turbo ignores a 200 to a form submit, so PRG is required for the
  confirmation to actually appear — caught in PR review.) The link opens `sessions#new`, a
  confirmation page whose button POSTs the token to `sessions#create` — so an
  email scanner prefetching the link can't sign anyone in. Tokens are stateless
  and self-expiring via `User.generates_token_for(:sign_in, expires_in:
  15.minutes)`, tied to `last_signed_in_at` so a link is single-use (signing in
  bumps the timestamp, invalidating it). `create` records the sign in
  (`sign_in_count` + `last_signed_in_at`) and redirects to the default team's
  dashboard; invalid and expired links are handled identically. Emails are plain
  text (`AuthMailer`, `.text.erb` only) — dev prints them to the console, prod
  sends via Resend. Added a global GOV.UK notification-banner flash partial (the
  app had none). Specs: the stub `click_button "Sign in"` is replaced by a
  `sign_in` helper that walks the real confirm step; new request + mailer specs
  cover the flow. 134 specs green; rubocop + brakeman clean.
* 2026-06-17 — Issue #32 (accounts), PR 3 of 3: sign up, plus closing the
  nested-controller IDOR (folded in because sign up is what makes a second user
  possible). (1) Authorization: each nested builder controller now authorizes
  the record it acts on through that record's own policy, matching the
  per-record pattern from PR 1 (`PagesController` already used `PagePolicy`).
  Positions and successors `authorize page, :update?` (PagePolicy); components,
  component positions and branch rules `authorize` the component via a new
  `ComponentPolicy` (`record.page.wizard` → team membership); builder-mode
  `answers` authorizes the page. So a signed-in user can no longer mutate
  another team's content by guessing ids. Run mode (the public share link) stays
  open — `answers` only authorizes in builder mode. A request spec proves a
  non-member is blocked from each endpoint while run-mode answers still work for
  anyone; ComponentPolicy has its own unit spec. (2) Sign up: a `Signup` model
  (encrypted email + full_name PII, like User; no uniqueness so duplicate
  pending signups stay neutral) with `generates_token_for :activation` and an
  `activate!` that creates a Personal Team + User + Membership and consumes
  itself (idempotent if the email is already taken). `SignUpsController` takes a
  name + email form and emails a confirmation link (or a sign-in link if the
  address is already registered), redirecting to the same neutral "check your
  email" page either way; `DestroySignupJob` (15-minute delay) cleans up
  unconfirmed signups. The link opens `ActivationsController#new`, whose button
  POSTs the token to #create (anti-prefetch, like sessions) → activate, sign in,
  land on the dashboard; invalid and expired links handled identically. The PR2
  "no account yet" email now points at sign up (pre-filling the address); landing
  + sign-in pages gained sign-up links. 164 specs green; rubocop + brakeman clean.

* 2026-06-17 — Issue #78 (button types): the "Continue button" component is now
  just "Button" with a `button_style` radio offering the five GOV.UK variants —
  continue (default), secondary, inverse, start, warning. A new `button_style`
  string column (default "continue") on `components`, validated against
  `Component::BUTTON_STYLES` at model + form level. The preview maps the style to
  its modifier class via `Component#button_modifier_class` (continue carries no
  modifier) and renders the arrow `govuk-button__start-icon` SVG for start
  buttons (`Component#start_button?`). Buttons stay `<button type="submit">` so
  every variant keeps driving the journey, and branch-rule editing is unchanged
  (it already keys off `kind == "button"`). The "Add continue button" control is
  now "Add button". 171 specs green.

* 2026-06-17 — Issue #76 (button target slug): a button can now name the page it
  goes to, fixing journeys where "next by position" is wrong after pages are
  reordered. New `target_slug` string column (default "") on `components`,
  parameterised on save like a branch rule's target. `Component#destination_slug`
  resolves in priority order: first matching branch rule → the button's own
  `target_slug` (the "else") → nil (linear next page); `ContinueForm` is otherwise
  unchanged (it already created missing targets in builder mode, so a button slug
  pointing at a not-yet-built page just creates it on click). The editor gains a
  "Go to page" field with copy explaining blank = next page, plus the same live
  "This page does not exist yet." warning branch rules have — for that, button
  updates take the branch-rule turbo response (refresh preview + missing-target
  hint, leave the editor pane so the slug field keeps focus) instead of
  `respond_with_panes`. 183 specs green; rubocop + brakeman clean.

* 2026-06-17 — Issue #74 (content between a heading-as-label and its input):
  previously a radios question using the page title as its legend glued the H1
  inside the `<legend>`, so no paragraph/list could sit between the heading and
  the options. Now the page H1 always renders at the top (with an id) and the
  radios `<fieldset>` references it via `aria-labelledby` instead of embedding
  it — the fieldset stays labelled for screen readers, and intervening
  components are ordinary positioned components. New `Page#heading_rendered_inline?`
  (true only for a text-input heading, which keeps its idiomatic
  `<h1><label>` wrapper); the preview's top-H1 condition switched from
  "no heading component" to "heading not rendered inline". No data changes. A
  new system spec recreates the EYTRP qualifications page (H1 → copy → list →
  radio options). 184 specs green; rubocop + brakeman clean. (Built on main,
  independent of the open panel PR #83, which also edits `_preview`.)

* 2026-06-17 — Issue #77 (GOV.UK panel): the page H1 can now sit in a coloured
  panel at the top of the page. New `pages.panel_style` (none/success/
  information) chosen by radios in the Page card, and `components.in_panel` for
  paragraphs/subheadings, toggled by an "Show inside the panel" checkbox that
  only appears once the page has a panel (mirrors the title-as-label toggle).
  Preview renders `pages/_panel` first (so the panel is always the first thing
  on the page), containing the H1 + in-panel body components in position order,
  then the loop skips in-panel components. `Page#heading_component` returns nil
  while a panel owns the title (inputs fall back to their own labels). "success"
  reuses the shipped green `govuk-panel--confirmation`; "information" is a custom
  blue, left-aligned `app-panel--information` modifier (the design system ships
  no blue variant). `pages#update` re-renders the builder pane when panel_style
  changes (so the per-component checkboxes appear/disappear) but only on that
  change, to avoid stealing focus while typing the title. UI chosen with the
  user: per-component checkbox over a nested "panel container" builder. 192
  specs green; rubocop + brakeman clean.

* 2026-06-18 — Page tabs on a single line (issues #42, #43). The reorder arrows
  riding in each tab became left/right (&larr;/&rarr;) to match the horizontal
  row (#43). The row no longer wraps (#42): instead of measuring widths in JS,
  the nav shows a fixed-size block of tabs around the current page (a generic
  `tab_window` helper slices the pages into blocks of `TAB_WINDOW_SIZE`, default
  8, overridable per render via a `max_tabs` local). When pages sit outside the
  block, a chevron arrow on that side links to the nearest one (last page of the
  previous block / first of the next), so each navigation just re-renders the
  right block — no JavaScript, no Stimulus controller. The arrows are plain
  links rendered in source order (left before the tabs, right after), and the
  windowing is covered by a fast helper unit spec plus a request spec instead of
  a slow resize-the-browser system test. 204 specs green; rubocop + brakeman
  clean. (Replaced an earlier JS measuring approach — simpler and server-driven,
  matching the rest of the app.)

## Decisions / open questions

* Authorization surface (issue #32): CLOSED in PR 3. PR 1 enforced team access on
  the entry points (`WizardsController`, `PagesController`); the deeper nested
  builder controllers (`components`, `branch_rules`, `component_positions`,
  `successors`, `positions`, `answers`) loaded by id without a team check, an IDOR
  that was theoretical only while one user existed. PR 3 (which adds sign up, so a
  second user can exist) authorizes each nested action through the acted-on
  record's own policy — `PagePolicy` for pages (positions, successors), a new
  `ComponentPolicy` for components and their branch rules — matching PR 1's
  per-record convention; the builder-mode branch of `answers` authorizes too
  while run mode stays public.

* Reordering and the page title (deferred, will refactor): the title is a Page
  attribute rendered first in the preview, and the title *card* is pinned first
  in the editor with no arrows — that part composes cleanly. The wrinkle is the
  single-question pattern (`title_as_label`): there the page's H1 is rendered
  *inside* an input component, which the arrows can now move below other
  components, putting the H1 in the middle of the page (invalid markup, and it
  breaks "title is always first"). Keeping it correct would mean pinning any
  `title_as_label` component to position 1 and special-casing the arrows to
  refuse to move it — leaking the title domain concept into the generic reorder
  mechanism. Left as-is for now; the real fix is to make the title a first-class
  first component (or otherwise pin the heading), then drop the special case.


* Heading size/caption live on Page, not as a component: the title is a
  singular, always-present Page attribute (one H1/page) that drives the slug
  and can be borrowed by an input via title_as_label; size/caption are
  presentation of that same title. Components stay for orderable, removable
  body elements (incl. the subheading h2).

* Sign in is a stubbed session flag — real accounts deferred until the
  builder flow works (per brief).
* Wizard name: MVP uses "Untitled wizard"; naming/renaming UI deferred.
* Preview is rendered inline (same document, inside the builder page) rather
  than an iframe. Simplest; revisit if CSS isolation becomes a problem.
* Run-mode form submissions don't persist answers anywhere yet — share mode
  is for look/feel feedback. Capturing answers is a later feature.
* Mobile/tablet builder layout deferred (desktop-only MVP per brief); the
  split pane does stack below 768px as a cheap fallback.
* Share links use sequential integer ids, so they are guessable. Swap to
  an unguessable token (e.g. `has_secure_token`) when accounts arrive.
* "Add input" offers Text input and Radio buttons; checkboxes, dates, etc.
  slot into the same disclosure + Component.kind pattern.
* Branch rules reference pages by slug string: renaming a slug silently
  orphans rules that point at it (they fall back to linear next). Surface
  this in the UI later (warn, or update rules when slugs change).
* Run-mode answers live in the session cookie (~4KB limit) and aren't
  persisted; capturing/reviewing respondents' answers is a later feature.
* Branch targets created from the builder are appended at the end of the
  journey, so "linear next" after a branch target can be surprising —
  fine while every branch page ends in its own button/rules.
