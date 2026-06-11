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

Component         one element on a page, ordered
  page_id
  position        integer, 1-based, unique within page
  kind            string enum: "paragraph" | "text_input" | "button"
  text            paragraph body / button label
  name            text_input: question name (internal identifier)
  label           text_input: visible label
  hint            text_input: hint text
```

Flat columns on `components` rather than STI/delegated types/JSON — simplest
thing that works for three kinds. Revisit if kinds multiply.

Navigation is linear for MVP: the continue button goes to the next page by
position (creating it in builder mode if it doesn't exist yet).

## Routes (RESTful only)

```
root                         landings#show (landing page)
resource  :session           stub sign in (create sets a session flag), destroy
resources :wizards           index (dashboard), create, show (run/share mode)
  resources :pages, shallow  create (next blank page), edit (THE BUILDER), update, show (run mode)
    resources :components, shallow  create, update, destroy
```

* `pages#edit` is the two-pane builder: left = controls, right = live preview.
* `pages#show` is run mode (used by share links; the preview pane reuses the
  same partial).
* Live preview updates: every builder field is a small form that auto-submits
  (generic Stimulus `autosubmit` controller, debounced) as a turbo-stream
  PATCH; the response replaces the preview pane.

## Form objects

* `WizardForm`     — create wizard (+ its first blank page)
* `PageForm`       — update title; create next page
* `ComponentForm`  — create/update/destroy components (kind-aware validation)

## Delivery steps

- [x] 0. Commit generated Rails app
- [x] 1. This plan
- [ ] 2. RSpec + Capybara (+ selenium headless Chrome) setup
- [ ] 3. Vendor govuk-frontend CSS/JS/assets (MVP: used as-is)
- [ ] 4. Landing page + stubbed sign in
- [ ] 5. Wizard + Page models; "New wizard" lands on builder with blank page
- [ ] 6. Title field with live preview (autosubmit + turbo stream)
- [ ] 7. Paragraph components: add, edit, remove — live preview
- [ ] 8. Continue button component: add, rename, click-through to next page
- [ ] 9. Text input component (text kind first), interactive in preview
- [ ] 10. Full journey feature spec mirroring the rough spec in the brief
- [ ] 11. Run mode / share link (wizards#show walks the journey)

## Progress log

* 2026-06-11 — Project start. Committed generated Rails 8.1 app. Wrote plan.

## Decisions / open questions

* Sign in is a stubbed session flag — real accounts deferred until the
  builder flow works (per brief).
* Wizard name: MVP uses "Untitled wizard"; naming/renaming UI deferred.
* Preview is rendered inline (same document, inside the builder page) rather
  than an iframe. Simplest; revisit if CSS isolation becomes a problem.
* Run-mode form submissions don't persist answers anywhere yet — share mode
  is for look/feel feedback. Capturing answers is a later feature.
* Mobile/tablet builder layout deferred (desktop-only MVP per brief).
