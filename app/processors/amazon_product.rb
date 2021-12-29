require 'cgi'

class AmazonProduct
  # HEADERS = {
  #   'dnt' => '1',
  #   'upgrade-insecure-requests' => '1',
  #   'user-agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36',
  #   'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
  #   'sec-fetch-site' => 'same-origin',
  #   'sec-fetch-mode' => 'navigate',
  #   'sec-fetch-user' => '?1',
  #   'sec-fetch-dest' => 'document',
  #   'referer' => 'https://www.amazon.com/',
  #   'accept-language' => 'en-GB,en-US;q=0.9,en;q=0.8'
  # }.freeze

  attr_accessor :urls

  def self.call(data)
    new(data).call
  end

  def initialize(data)
    @urls = data[:urls].map! do |url|
      url = CGI.escape(url)
      url.prepend("https://api.proxycrawl.com/?token=#{ENV['PROXYCRAWL_TOKEN']}&url=")
    end
  end

  def call
    htmls = AsyncLoader.fetch(urls)
    products = Sync do
      barrier = Async::Barrier.new
      values = []
      htmls.each_with_index do |html, index|
        barrier.async do
          product = Html::AmazonProduct.parse(html)
          values << product.merge(url: urls[index])
        end
      end

      Rails.logger.debug 'AsyncHttp#wait'
      barrier.wait
      values
    end
    products.each do |product|
      Product.find_or_initialize_by(url: product[:url]).update_attributes(product.deep_compact)
    end
  end
end
