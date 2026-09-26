ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Requests the Inertia JSON payload directly, skipping the HTML shell and its Vite assets
    def inertia_get(path, **params)
      get path, params:, headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => ViteRuby.digest }
    end

    def inertia_page
      response.parsed_body
    end

    def sign_in(email)
      post login_path, params: { email: }
    end
  end
end
