class GetUrlsWorker
  include Sneakers::Worker
  from_queue 'urls'

  def work(msg)
    msg = Oj.load(msg, symbolize_names: true)
    return if msg[:consumer] != 'Crawler'

    msg[:processor].constantize.call(msg[:data])
    ack!
  rescue StandardError => e
    Sneakers.logger.error("Error while fetching urls #{e.class} #{e.message}")
    Sneakers.logger.debug(e.backtrace)
    reject!
  end
end
