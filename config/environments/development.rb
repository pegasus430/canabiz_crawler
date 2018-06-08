Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  #error handling
  config.consider_all_requests_local = false
  
  #braintree
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = ENV['merchant_id']
  Braintree::Configuration.public_key =  ENV['public_key']
  Braintree::Configuration.private_key = ENV['private_key']
  
  #redis
  # config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 90.minutes }
  
  # #redis
  #   config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 90.minutes }

  #THIS WILL BE NEEDED FOR PAGE CACHING OR FRAGMENT CACHING    
  # config.cache_store = :redis_store, {
  #   host: "ec2-35-168-107-180.compute-1.amazonaws.com",
  #   port: 9979,
  #   db: 0,
  #   password: "p384db25b425919fe4297a5aa76d4ebea27858fb42d40ec0864e358f1516e5c57",
  #   namespace: "cache"
  # }
end
