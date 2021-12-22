class TopSearches
  attr_accessor :urls

  def self.call(data)
    new(data).call
  end

  def initialize(data)
    @urls = data[:urls]
  end

  def call
    html = AsyncLoader.fetch(urls).first
  end
end
