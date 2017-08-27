source 'https://rubygems.org'

#STEVE ADDITIONS:
gem 'will_paginate', '3.0.7' # PAGINATION
gem 'bootstrap-will_paginate', '0.0.10' # BOOTSTRAP STYLING
gem 'bootstrap-sass', '~> 3.3.6' # BOOTSTRAP STYLING
gem 'httparty', '~> 0.13.7' #External API Integration
gem 'bcrypt', '~> 3.1.7' #PASSWORD DIGEST
gem 'rails_autolink', '~> 1.1', '>= 1.1.6' #helps to recognize a link in a string and output it as a link
#gem 'kaminari', '~> 0.17.0' #Infinite Scrolling
#gem 'jquery-turbolinks', '~> 2.1' #also needed for Infinite Scrolling so it works with Links
gem 'social-share-button', '~> 0.9.0' #social sharing
gem 'friendly_id', '~> 5.0.0' #use the titles as the urls
gem "skylight" #app monitoring
gem 'sprockets-rails', :require => 'sprockets/railtie' #trying to minify css and js

#BACKGROUND JOBS
gem 'sucker_punch', '~> 2.0' #BACKGROUND JOB ENQUEUE
gem 'sidekiq', '~> 4.2', '>= 4.2.10' #background jobs - switching from sucker punch
gem 'redis', '~> 3.3', '>= 3.3.3' #needed for sidekiq
gem 'sinatra', '~> 1.4', '>= 1.4.8' #needed for sidekiq
gem 'sidekiq-cron', '~> 0.6.0' #schedule sidekiq job
gem 'sidekiq-failures', '~> 0.4.5' #see failed sidekiq jobs

#html safe truncation
gem "nokogiri"
gem "htmlentities"
gem 'truncate_html', '~> 0.9.3'

#css for emails
gem 'premailer-rails', '~> 1.9', '>= 1.9.5' # to style emails
#gem 'premailer', '~> 1.10', '>= 1.10.2' #to styling email


#TWITTER GEMS
gem 'twitter' #TWITTER
gem 'oauth', '~> 0.5.1' #Needed for Twitter

#gems for image management
gem 'carrierwave', '~> 0.11.2'
gem 'mini_magick', '~> 4.5', '>= 4.5.1'
gem 'fog', '~> 1.38'
gem 'figaro', '~> 1.1', '>= 1.1.1'
gem 'unf', '~> 0.1.4'
gem 'carrierwave-imageoptimizer', '~> 1.4'
gem 'jpegoptim', '~> 0.2.1' #maybe?

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2' #for test methods
end

#for test methods
group :test do
  gem 'capybara', '2.7.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'heroku-deflater'
end
