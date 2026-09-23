# Headquarter

Headquarter is the central hub for managing Shinobi workspace operations. Built with Ruby on Rails.

## Branch information

You should create a new branch for an issue, and raise a pull request.

- `main` most up to date yet dirty code merged from other issue branches
- Issue branches should implements feature as described in the issue description
- Tags on `main` are code that have been deployed to production

## CI pipeline note

- GitHub Actions is used for CI/CD pipeline
- Kamal 2 is used for managing Rails deployment
- For now we only have production environment

## Development requirements

- **Environment** UNIX based is recommended (can use WSL on Windows)
- **Database** SQLite for development and production
- **Ruby Version** 4.0.3
- **Rails Version** ~> 8.1.3
- **Node.js Version** 24 LTS or newer
- **Frontend** Svelte and TailwindCSS through Inertia and Vite

## Code style

Must respect the Rails best practices. Also ensure that your changes are passed by below linters. Auto checked by GitHub Actions.

- `rails test`
- `rails zeitwerk:check`
- `rubocop`
- `erb_lint --lint-all`
- `brakeman`
- `npm run check`

You can run everything at once locally with `bin/ci`.

## Infrastructure environment

### Running locally

1. Make sure you have Ruby on Rails and Node.js installed.
2. Make sure `config/master.key` file is exist.
3. Copy `.env.example` to `.env` and adjust the values if needed.
4. Install node dependencies `npm install`.
5. Run database setup `rails db:setup`.
6. You're good to go, run `./bin/dev` or `rails server` to spin up development servers or `./bin/rails test` to run test suites.

## Deployment

> To be defined

## Environment variables

### Build-Time (GitHub Actions)

#### Secrets

> To be defined

#### Variables

> To be defined

### Run-Time (Application)

These are variables required to run in `production` environment. Advanced variables can be found in `config/puma.rb` to configure server thread.

- `RAILS_ENV` Rails running environment, should always be `production` when running in a server
- `RAILS_MASTER_KEY` to decrypt the in-app credentials

## Other notes

- We use Letter Opener for development email preview

## Credits

Authored by Uchiha Itachi.
