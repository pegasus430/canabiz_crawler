#Sidekiq::Cron::Job.create(name: 'Leafly Dispensary', cron: '0 */2 * * *', class: 'LeaflyDispensaryWorker')

if Rails.env.production?
	Sidekiq::Cron::Job.create(name: 'Leafly every 2 hours on the hour', cron: '0 */2 * * *', class: 'LeaflyWorker')
	Sidekiq::Cron::Job.create(name: 'CannaLawBlog every 2 hours on the 5 min', cron: '5 */2 * * *', class: 'CannaLawBlogWorker')
	Sidekiq::Cron::Job.create(name: 'CannabisCulture every 2 hours on the 10 min', cron: '10 */2 * * *', class: 'CannabisCultureWorker')
	Sidekiq::Cron::Job.create(name: 'DopeMagazine every 2 hours on the 15 min', cron: '15 */2 * * *', class: 'DopeMagazineWorker')
	Sidekiq::Cron::Job.create(name: 'FourTwentyTimes every 2 hours on the 20 min', cron: '20 */2 * * *', class: 'FourTwentyTimesWorker')
	Sidekiq::Cron::Job.create(name: 'HighTimes every 2 hours on the 25 min', cron: '25 */2 * * *', class: 'HighTimesWorker')
	Sidekiq::Cron::Job.create(name: 'MarijuanaStocks every 2 hours on the 30 min', cron: '30 */2 * * *', class: 'MarijuanaStocksWorker')
	Sidekiq::Cron::Job.create(name: 'Marijuana.com every 2 hours on the 35 min', cron: '35 */2 * * *', class: 'MarijuanaWorker')
	Sidekiq::Cron::Job.create(name: 'MjBizDaily every 2 hours on the 40 min', cron: '40 */2 * * *', class: 'MjBizDailyWorker')
	Sidekiq::Cron::Job.create(name: 'TheCannabist every 2 hours on the 45 min', cron: '45 */2 * * *', class: 'TheCannabistWorker')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 1', cron: '0 */2 * * *', class: 'WeedMapsWorker1')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 1', cron: '0 */2 * * *', class: 'WeedMapsWorker2')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 1', cron: '0 */2 * * *', class: 'WeedMapsWorker3')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 1', cron: '0 */2 * * *', class: 'WeedMapsWorker4')
end