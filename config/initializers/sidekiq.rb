require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['SIDEKIQ_ADMIN_USERNAME'], ENV['SIDEKIQ_ADMIN_PASSWORD']]
end

#worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)