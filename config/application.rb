require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JurassicInterviewRailsApi
  class Application < Rails::Application

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Preventing automatic test/spec generation. NOTE: This is because we're going to use
    # request specs as a full-stack testing mechanism
    config.generators do |g|
      g.view_specs false
      g.helper_specs false
      g.controller_specs false
      g.model_specs false
      g.routing_specs false
    end

  end
end
