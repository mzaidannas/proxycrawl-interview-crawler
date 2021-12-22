module Processors
  class TopSearches
    attr_accessor :url

    def self.call(data)
      new(data).call
    end

    private

    def initialize(data)
      @url = data[:url]
    end

    def call
      html = AsyncLoader.fetch([url]).first
      debugger
    end
  end
end
