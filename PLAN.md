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
Wizard            the prototype/journey being built
  name            string (defaults to first page title later; MVP: "Untitled wizard")

Page              one screen in the journey, ordered
  wizard_id
  position        integer, 1-based, unique within wizard
  title           string  (the page H1 — always present in the builder)
  slug            string, unique within wizard; tracks the title
                  ("What is your name" -> what-is-your-name) until the user
                  customises it; defaults to page-N while untitled

Component         one element on a page, ordered
  page_id
  position        integer, 1-based, unique within page
  kind            string enum: "paragraph" | "text_input" | "radios" | "button"
  text            paragraph body / button label
  name            inputs: question name; required, generated unique per
                  wizard (question-N); parameterised form = "input key"
  label           inputs: visible label (radios: fieldset legend)
  hint            inputs: hint text
  options         radios: one option per line; submitted value is the
                  parameterised option label

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
page; with no match the journey continues linearly by position (creating the
next page in builder mode if needed).

## Routes (RESTful only)

```
root                         landings#show (landing page)
resource  :session           stub sign in (create sets a session flag), destroy
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

## Decisions / open questions

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
