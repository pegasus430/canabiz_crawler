class HardWorker
  include Sidekiq::Worker

  def perform()
    # Do something
    logger.info "Sidekiq job is running"
  end
end
