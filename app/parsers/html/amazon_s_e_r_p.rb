module Html
  class AmazonSERP
    SELECTORS = {
      products: {
        css: 'div[data-component-type="s-search-result"]',
        multiple: true,
        type: 'text',
        children: {
          title: {
            css: 'h2 a.a-link-normal.a-text-normal',
            type: 'text'
          },
          url: {
            css: 'h2 a.a-link-normal.a-text-normal',
            type: 'Attribute',
            attribute: 'href',
            postprocess: ->(url) { url&.prepend('https://www.amazon.com') }
          },
          rating: {
            css: 'div.a-row.a-size-small span:nth-of-type(1)',
            type: 'Attribute',
            attribute: 'aria-label',
            postprocess: ->(rating) { rating&.to_f }
          },
          reviews: {
            css: 'div.a-row.a-size-small span:nth-of-type(2)',
            type: 'Attribute',
            attribute: 'aria-label',
            postprocess: ->(reviews) { reviews&.to_i }
          },
          price: {
            css: 'span.a-price:nth-of-type(1) span.a-offscreen',
            type: 'text',
            postprocess: ->(price) { price&.[](1..)&.to_f } # Safe navigation operator with index operator
          }
        }
      }
    }.freeze

    def self.parse(html)
      new(html).parse
    end

    def initialize(html)
      @html = html
    end

    def parse
      Nokogiri.HTML(@html).css(SELECTORS[:products][:css]).map do |products|
        SELECTORS[:products][:children].each_with_object({}) do |(key, value), hash|
          hash[key] = value[:type] == 'text' ? products.css(value[:css]).first&.text : products.css(value[:css]).first&.attr(value[:attribute])
          hash[key] = value[:postprocess].call(hash[key]) if value[:postprocess]
        end
      end
    end
  end
end
