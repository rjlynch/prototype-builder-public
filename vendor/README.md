# Vendored dependencies

## govuk-frontend v6.2.0

Source: https://github.com/alphagov/govuk-frontend/releases/tag/v6.2.0
(release-v6.2.0.zip). MVP uses it as-is; longer term we need to replace
crown/GOV.UK branding to avoid copyright infringement.

Where the files live and why:

* `app/assets/stylesheets/govuk-frontend.css` — the precompiled minified CSS,
  served by Propshaft. Linked explicitly (before application.css) in the
  layout.
* `vendor/javascript/govuk-frontend.js` — the precompiled ES module, pinned
  in `config/importmap.rb`. `initAll()` is run on `turbo:load` from
  `app/javascript/application.js`.
* `public/assets/fonts`, `public/assets/images`, `public/assets/manifest.json`
  — the CSS hardcodes `/assets/fonts/...` and `/assets/images/...` URLs, so
  these are served statically from `public/`. NOTE: `rails assets:clobber`
  deletes `public/assets` — re-copy from the release zip if that happens.

To upgrade: download the new release zip, copy the same four pieces over,
update the version in this file and in `config/importmap.rb`'s comment, run
the system specs (`spec/system/govuk_frontend_spec.rb` checks the wiring).
