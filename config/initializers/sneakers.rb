if ENV['AMQP_URL']
  connection = Bunny.new(ENV['AMQP_URL'], ssl: ENV['RAILS_ENV'].in?(%w[production staging]))
  Sneakers.configure({
                       connection: connection,
                       pid_path: 'tmp/pids/sneakers.pid',
                       workers: ENV.fetch('SNEAKERS_CONCURRENCY', 2).to_i,
                       prefetch: ENV.fetch('SNEAKERS_PREFETCH', 10).to_i,  # Grab 10 jobs together. Better speed
                       threads: ENV.fetch('SNEAKERS_THREADS', 10).to_i,
                       env: ENV['RAILS_ENV'],
                       durable: true, # Is queue durable?
                       ack: true      # Must we acknowledge?
                     })
  Sneakers.logger = Rails.logger
  Sneakers.logger.level = ENV.fetch('LOG_LEVEL', :info).to_sym
end
