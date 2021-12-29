module Html
  class AmazonProduct
    SELECTORS = {
      name: {
        css: '#productTitle',
        type: 'Text'
      },
      price: {
        css: '#price_inside_buybox',
        type: 'Text',
        postprocess: ->(price) { price&.[](1..)&.to_f }
      },
      short_description: {
        css: '#featurebullets_feature_div',
        type: 'Text'
      },
      images: {
        css: '.imgTagWrapper img',
        type: 'Attribute',
        attribute: 'data-a-dynamic-image'
      },
      rating: {
        css: 'span.arp-rating-out-of-text',
        type: 'Text',
        postprocess: ->(rating) { rating&.to_f }
      },
      number_of_reviews: {
        css: 'a.a-link-normal h2',
        type: 'Text',
        postprocess: ->(reviews) { reviews&.to_i }
      },
      variants: {
        css: 'form.a-section li',
        multiple: true,
        type: 'Text',
        children: {
          name: {
            css: '',
            type: 'Attribute',
            attribute: 'title'
          },
          asin: {
            css: '',
            type: 'Attribute',
            attribute: 'data-defaultasin'
          }
        }
      },
      product_description: {
        css: '#productDescription',
        type: 'Text'
      },
      sales_rank: {
        css: 'li#SalesRank',
        type: 'Text'
      },
      link_to_all_reviews: {
        css: 'div.card-padding a.a-link-emphasis',
        type: 'Link'
      }
    }.freeze

    def self.parse(html)
      new(html).parse
    end

    def initialize(html)
      @html = html
    end

    def parse
      Nokogiri.HTML(@html).tap do |product|
        SELECTORS.each_with_object({}) do |(key, value), hash|
          hash[key] = value[:type] == 'text' ? product.css(value[:css]).first&.text : product.css(value[:css]).first&.attr(value[:attribute])
          hash[key] = value[:postprocess].call(hash[key]) if value[:postprocess]
        end
      end
    end
  end
end
