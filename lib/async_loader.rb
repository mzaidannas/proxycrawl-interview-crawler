require 'async'
require 'async/barrier'
require 'async/http/internet/instance'
require 'kernel/sync'

class AsyncLoader
  def fetch(urls, headers: {})
    Sync do
      internet = Async::HTTP::Internet.instance
      barrier = Async::Barrier.new
      values = []

      urls.each do |url|
        barrier.async do
          Rails.logger.debug "AsyncHttp#get: #{url}"
          begin
            response = internet.get(url, headers)
            body = JSON.parse(response.read)
            values << body
          ensure
            response.finish
          end
          Rails.logger.debug "AsyncHttp#fulfill: #{url}"
        end
      end

      Rails.logger.debug 'AsyncHttp#wait'
      barrier.wait
      values
    end
  end
end
