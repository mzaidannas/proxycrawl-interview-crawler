class AmazonSERP
  # HEADERS = {
  #   'authority' => 'www.amazon.com',
  #   'pragma' => 'no-cache',
  #   'cache-control' => 'no-cache',
  #   'dnt' => '1',
  #   'upgrade-insecure-requests' => '1',
  #   'user-agent' => 'Mozilla/5.0 (X11; CrOS x86_64 8172.45.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.64 Safari/537.36',
  #   'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
  #   'sec-fetch-site' => 'none',
  #   'sec-fetch-mode' => 'navigate',
  #   'sec-fetch-dest' => 'document',
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
    # @urls = data[:urls]
  end

  def call
    htmls = AsyncLoader.fetch(urls)
    products = Sync do
      barrier = Async::Barrier.new
      values = []
      htmls.each do |html|
        barrier.async do
          products = Html::AmazonSERP.parse(html)
          values << products
        end
      end

      Rails.logger.debug 'AsyncHttp#wait'
      barrier.wait
      values
    end
    products.flatten!
    products.each_slice(10) do |products_batch|
      Product.upsert_all(products_batch, unique_by: :url)
      Publisher.push_data(
        { consumer: 'Crawler', processor: 'AmazonProduct',
          data: { urls: products_batch.map(&:url) } }, 'urls'
      )
    end
  end
end
