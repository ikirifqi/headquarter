source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.3', '>= 8.1.3.1'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 2.1'
# json 3 drops the positional options hash ActiveSupport 8.1 passes to JSON.parse, which breaks
# reading encrypted cookies (and so sessions). Lift once Rails supports json 3.
gem 'json', '~> 2.21'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # A Ruby static code analyzer and formatter, based on the community Ruby style guide.
  gem 'rubocop', '1.91.0', require: false

  # A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  gem 'rubocop-rails', '2.38.0', require: false

  # An extension of RuboCop focused on code performance checks.
  gem 'rubocop-performance', '1.27.0', require: false

  # A RuboCop plugin for Rake
  gem 'rubocop-rake', '0.7.1', require: false

  # An extension of RuboCop focused on thread-safety checks.
  gem 'rubocop-thread_safety', '0.8.0', require: false

  # Code style checking for Capybara files.
  gem 'rubocop-capybara', '3.0.0', require: false

  # RuboCop rules for detecting and autocorrecting undecorated strings for i18n
  gem 'rubocop-i18n', '3.3.0', require: false

  # Code style checking for Minitest files.
  gem 'rubocop-minitest', '0.40.0', require: false

  # RuboCop's AST extensions and NodePattern functionality
  gem 'rubocop-ast', '1.50.0', require: false

  # Lint your ERB or HTML files
  gem 'erb_lint', '0.9.0', require: false

  # Load environment variables from .env into ENV in development and test
  gem 'dotenv-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Preview email in the default browser instead of sending it
  gem 'letter_opener'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end

gem 'inertia_rails', '~> 3.22'

gem 'vite_rails', '~> 3.11'
