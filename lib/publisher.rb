require 'bunny'
require 'oj'

class Publisher
  class << self
    def publish(exchange, message = {})
      x = channel.fanout("crawler.#{exchange}", durable: true)
      x.publish(Oj.dump(message))
    end

    def channel
      @channel ||= connection.create_channel
    end

    def push_data(obj, queue_name)
      q = channel.queue(queue_name, durable: true)
      channel.default_exchange.publish(Oj.dump(obj), routing_key: q.name)
    end

    def connection
      @connection ||= Bunny.new(ENV['AMQP_URL'])
      Console.logger.info 'Connecting to Rabbitmq'
      @connection.start
    end

    def close
      @connection.close
    end
  end
end
