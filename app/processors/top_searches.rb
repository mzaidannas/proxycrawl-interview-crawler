require 'cgi'
class TopSearches
  # HEADERS = {
  #   'authority' => 'www.semrush.com',
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
    html = AsyncLoader.fetch(urls).first
    top_searches = Html::TopSearches.parse(html)
    top_searches.each_slice(10) do |searches|
      search_urls = searches.map do |search|
        "https://www.amazon.com/s?k=#{search}"
      end
      Publisher.push_data(
        { consumer: 'Crawler', processor: 'AmazonSERP',
          data: { urls: search_urls } }, 'urls'
      )
    end
  end
end
