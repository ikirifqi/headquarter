# AGENTS.md

Guidance for AI coding agents working in the Headquarter repository.

## Project overview

Headquarter is the central hub for managing Shinobi workspace operations. It is a Ruby on Rails
monolith that renders a Svelte single-page frontend through Inertia, with assets bundled by Vite.
There is no separate API client: controllers return Inertia responses and Svelte components receive
them as props.

- **Ruby** 4.0.3 (`.ruby-version`), **Rails** `~> 8.1.3`
- **Node.js** 24 LTS or newer
- **Database** SQLite in every environment (`storage/*.sqlite3`)
- **Frontend** Svelte 5 (runes) + TailwindCSS 4 via Inertia and Vite
- **Background jobs / cache / cable** Solid Queue, Solid Cache, Solid Cable (all database backed)
- **Deployment** Kamal 2 to a single `production` environment; CI on GitHub Actions
- Application timezone is `Asia/Jakarta` (`config/application.rb`)

## Commands

Run everything from the repository root.

| Task | Command |
| --- | --- |
| Full local CI (setup, all linters, security, tests) | `bin/ci` |
| Dev servers (Rails + Vite) | `bin/dev` |
| Rails server only | `bin/rails server` |
| Tests | `bin/rails test` |
| Tests including system tests | `bin/rails test:all` |
| Single test file | `bin/rails test test/models/foo_test.rb` |
| Single test by line | `bin/rails test test/models/foo_test.rb:42` |
| Autoloader check | `bin/rails zeitwerk:check` |
| Ruby lint | `bin/rubocop` (`bin/rubocop -a` to autocorrect) |
| ERB lint | `bundle exec erb_lint --lint-all` |
| Frontend checks (types + eslint + prettier) | `npm run check` |
| Frontend autofix | `npm run lint:fix` and `npm run format` |
| Security scan | `bin/brakeman` and `bin/bundler-audit` |
| Database setup | `bin/rails db:setup` |

`bin/ci` is defined in `config/ci.rb` and is the same set of steps GitHub Actions runs in
`.github/workflows/checks.yml`. Prefer running the individual command for the area you touched, then
`bin/ci` before finishing a change.

## Local setup

1. Install Ruby and Node.js at the versions above.
2. Ensure `config/master.key` exists (not in version control).
3. Copy `.env.example` to `.env` and adjust values.
4. `bundle install` and `npm install`.
5. `bin/rails db:setup`.
6. `bin/dev` to start Rails and Vite together.

Development requests to `127.0.0.1` are redirected to `localhost` (see `config/routes.rb`) so the
Rails host matches the Vite dev server origin. Always use `http://localhost:3000`.

Outgoing mail in development is opened in the browser by `letter_opener` instead of being sent.

## Repository layout

```
app/
  controllers/         Rails controllers; Inertia pages inherit from InertiaController
  models/              Active Record models
  services/            Service objects inheriting from ApplicationService
  helpers/ jobs/ mailers/
  views/layouts/       application.html.erb mounts the Vite entrypoints
  assets/stylesheets/  Propshaft manifest (app-level CSS, not the Svelte styles)
  frontend/            Vite source root (config/vite.json sourceCodeDir)
    entrypoints/       application.ts, inertia.ts, application.css (Tailwind entry)
    pages/             Svelte pages resolved by Inertia, mirroring controller paths
    types/             Shared TypeScript types (SharedProps, FlashData)
    assets/            Images imported by the frontend
config/                Rails config, ci.rb, deploy.yml (Kamal), vite.json
db/                    seeds.rb and the Solid* schema files
test/                  Minitest suites mirroring app/
```

## Ruby conventions

- RuboCop (`.rubocop.yml`) is the source of truth and runs with `NewCops: enable` plus the rails,
  performance, rake, thread_safety, capybara, i18n, and minitest plugins. Match its output rather
  than reformatting by hand.
- **String literals use single quotes** unless interpolation or escaping requires otherwise.
- `# frozen_string_literal: true` is **not** required — `Style/FrozenStringLiteralComment` is
  disabled. Some existing files still carry it; leave those alone, do not add it to new files.
- Top-level class documentation is required for regular classes. It is excluded for
  `application_*.rb` / `base_*.rb`, helpers, `config/application.rb`, `db/**`, and `test/**`.
- User-facing strings go through I18n (`config/locales/en.yml`); `rubocop-i18n` flags undecorated
  strings in views.
- Keep `bin/rails zeitwerk:check` green: file names must match constant names.

### Service objects

Business logic that does not belong on a model or controller goes in `app/services/` and inherits
from `ApplicationService`:

```ruby
# Sends the weekly digest to every active member
class SendWeeklyDigest < ApplicationService
  attr_reader :delivered_count

  def initialize(team)
    @team = team
  end

  def call
    @delivered_count = ...
  end
end

SendWeeklyDigest.call(team).delivered_count
```

`ApplicationService.call` builds the instance, invokes `#call`, and returns the instance. Expose
results with `attr_reader` — the return value of `#call` is ignored. Services may define their own
constructor without calling `super` (`Lint/MissingSuper` is excluded for `app/services/**`).

### Controllers and Inertia

- `ApplicationController` is the base for all controllers and restricts the app to modern browsers.
- Controllers that render Inertia pages inherit from `InertiaController`, which is the place to add
  `inertia_share` props available to every page.
- `render inertia: { ... }` resolves a Svelte component under `app/frontend/pages/` matching the
  controller and action path (for example `InertiaExampleController#index` renders
  `app/frontend/pages/inertia_example/index.svelte`).
- Inertia options live in `config/initializers/inertia_rails.rb` (history encryption, error hash,
  asset versioning through `ViteRuby.digest`).

## Frontend conventions

- Prettier (`.prettierrc.json`) governs formatting: **no semicolons**, single quotes, trailing
  commas everywhere, 100 character print width, with the Svelte and Tailwind plugins.
- ESLint flat config (`eslint.config.js`) layers the TypeScript and Svelte recommended rules; run
  `npm run lint` rather than guessing.
- Svelte 5 runes (`$props`, `$state`, `$derived`) — not the Svelte 4 `export let` API.
- Type checking covers `.ts`, `.js`, and `.svelte` under `app/frontend` (`checkJs` is on).
- Import aliases `@/*` and `~/*` both resolve to `app/frontend/*`.
- Tailwind 4 is configured through CSS in `app/frontend/entrypoints/application.css` (`@import`
  and `@plugin`), not a `tailwind.config.js`.
- Props shared from `InertiaController` must be reflected in `app/frontend/types/index.ts`
  (`SharedProps`) so pages stay typed.

## Testing

- Minitest with fixtures; `test/test_helper.rb` loads `fixtures :all` and parallelizes by processor
  count.
- Tests mirror `app/` structure: `test/models/`, `test/controllers/`, `test/integration/`,
  `test/mailers/`, `test/helpers/`.
- System tests use Capybara and Selenium and only run under `bin/rails test:all` / `bin/ci`.
- `rubocop-minitest` applies to `test/**`; the documentation cop does not.

## Definition of done

A change is complete only when all of the following pass, since GitHub Actions enforces them:

1. `bin/rubocop`
2. `bundle exec erb_lint --lint-all`
3. `npm run check`
4. `bin/rails zeitwerk:check`
5. `bin/brakeman` and `bin/bundler-audit`
6. `bin/rails test` (or `test:all` when system tests are relevant)

`bin/ci` runs the whole sequence in one pass.

## Git workflow

- Work happens on an issue branch cut from an up-to-date `main`; `main` holds merged issue work and
  tags on `main` mark production deploys.
- Commits follow Conventional Commits with a lowercase, imperative subject:
  `feat:`, `fix:`, `chore:`, `docs:`, `ci:`, `test:`, `refactor:`.
- Keep commits semantic and atomic — one logical change per commit, split by context instead of
  bundling unrelated edits together.
- Never commit `config/master.key`, `.env`, or anything under `storage/`.

## Things to avoid

- Do not add a `tailwind.config.js`; Tailwind 4 configuration is CSS-first.
- Do not introduce Turbo/Hotwire patterns — navigation is handled by Inertia.
- Do not hand-edit `db/*_schema.rb` (Solid Queue/Cache/Cable schemas) or generated lockfiles.
- Do not bypass linters with inline disables unless there is a documented reason.
- Do not open pull requests unless explicitly asked; this repository may be operated without them.
