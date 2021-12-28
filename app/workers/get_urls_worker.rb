class GetUrlsWorker
  include Sneakers::Worker
  from_queue 'urls'

  def work(msg)
    msg = Oj.load(msg, symbolize_names: true)
    return if msg[:consumer] != 'Crawler'

    msg[:processor].constantize.call(msg[:data])
    ack!
  rescue StandardError => e
    Sneakers.logger.failure(e)
    Sneakers.logger.info("Error while fetching urls #{e.class} #{e.message}")
    reject!
  end
end
