# frozen_string_literal: true

# Renders the example Inertia page showing the framework versions in use
class InertiaExampleController < InertiaController
  def index
    render inertia: {
      rails_version: Rails.version,
      ruby_version: RUBY_DESCRIPTION,
      rack_version: Rack.release,
      inertia_rails_version: InertiaRails::VERSION
    }
  end
end
