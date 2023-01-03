source 'https://rubygems.org'

#STEVE ADDITIONS:
gem 'will_paginate', '3.0.7' # PAGINATION
gem 'bootstrap-will_paginate', '0.0.10' # BOOTSTRAP STYLING
gem 'bootstrap-sass', '~> 3.3.6' # BOOTSTRAP STYLING
gem 'geocoder', '~> 1.4', '>= 1.4.4' #GET USER / DISPENSARY LOCATION
gem 'gmaps4rails', '~> 2.1', '>= 2.1.2' #INTEGRATE GOOGLE MAPS
gem 'httparty', '~> 0.21.0' #External API Integration
gem 'bcrypt', '~> 3.1.7' #PASSWORD DIGEST
gem 'rails_autolink', '~> 1.1', '>= 1.1.6' #helps to recognize a link in a string and output it as a link
gem 'social-share-button', '~> 0.9.0' #social sharing
gem 'friendly_id', '~> 5.0.0' #use the titles as the urls
gem 'skylight', '~> 1.5', '>= 1.5.1' #app monitoring
gem 'sprockets-rails', :require => 'sprockets/railtie' #trying to minify css and js
gem 'canonical-rails', '~> 0.2.1' #automatically add canonical meta tag to each page
gem 'owlcarousel-rails', github: 'acrogenesis/owlcarousel-rails', branch: 'master'
gem 'left_join', '~> 0.2.1' #do left_join queries
gem 'hairtrigger', '~> 0.2.20' #allow for trigger use
gem 'country_select' #select list of countries

#ACTIVE ADMIN
gem 'devise'
gem 'cancancan'
gem 'activeadmin'
gem 'active_admin_role'
gem 'active_skin'

#ECOMMERCE
gem 'toastr-rails' #for notifications
gem "braintree" #payment processing
gem 'bootstrap-modal-rails', '~> 2.2', '>= 2.2.5' #for customer to select quantity and unit

#BACKGROUND JOBS
gem 'sucker_punch', '~> 2.0' #BACKGROUND JOB ENQUEUE
gem 'sidekiq', '~> 4.2', '>= 4.2.10' #background jobs - switching from sucker punch

gem 'sinatra', '~> 1.4', '>= 1.4.8' #needed for sidekiq
gem 'sidekiq-cron', '~> 0.6.0' #schedule sidekiq job
gem 'sidekiq-failures', '~> 0.4.5' #see failed sidekiq jobs

#REDIS
gem 'redis', '~> 3.3', '>= 3.3.3' #needed for sidekiq
gem 'redis-rails'

#html safe truncation
gem "nokogiri"
gem "htmlentities"
gem 'truncate_html', '~> 0.9.3'

#css for emails
gem 'premailer-rails', '~> 1.9', '>= 1.9.5' # to style emails

#TWITTER GEMS
gem 'twitter' #TWITTER
gem 'oauth', '~> 0.5.1' #Needed for Twitter

#IMAGE MANAGEMENT
gem 'carrierwave', '~> 0.11.2' #rails tool for file uploads
gem 'mini_magick', '~> 4.5', '>= 4.5.1' #handles file sizes - so they aren't too big - can resize images
gem 'fog', '~> 1.38' #connects to AWS CDN
gem 'figaro', '~> 1.1', '>= 1.1.1' #protects environment variables - so they don't go up to GitHub or anything
gem 'unf', '~> 0.1.4' #protects against any issues with carrier wave
gem 'carrierwave-imageoptimizer', '~> 1.4'
gem 'jpegoptim', '~> 0.2.1'

#FONT AWESOME
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'
gem 'font-awesome-sass', '~> 4.7'

# JQUERY
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'

# STANDARD
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc



group :development, :test do
  gem 'byebug'
  gem 'sqlite3'
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2' #for test methods
end

#for test methods
group :test do
  gem 'capybara', '2.7.1'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'heroku-deflater'
end
