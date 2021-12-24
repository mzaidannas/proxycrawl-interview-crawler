module Html
  class TopSearches
    def self.parse(html)
      new(html).parse
    end

    def initialize(html)
      @html = html
    end

    def parse
      Nokogiri.HTML(@html).css('table>tbody>tr').map do |item|
        item.css('td:nth-child(2)').map(&:text).first
      end
    end
  end
end
