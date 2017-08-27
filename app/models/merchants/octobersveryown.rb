module Merchants
  module Octobersveryown
    def self.extended(merchant)
      merchant.indexer = OctobersveryownIndexer
      merchant.extend Parser
    end

    class OctobersveryownIndexer < Indexer
    end

    module Parser
      def attrs_from_node(node)
        name_node, price_node = node.css('p')
        link_node             = node.css('a').first
        price                 = price_node.content.strip[1..-1].to_f
        name                  = AsciiFolding.fold(name_node.at_css('a').content.strip)
        link                  = link_node['href']
        sku                   = Digest::MD5.hexdigest(name.titleize)

        { # There is a sku, but its only shown
          # by fetching the article
          sku:  sku,
          name: name.titleize,
          # We can actually get a better description
          # by fetching the page and reading the meta tag
          description: name.capitalize,
          link:        '%s%s' % [domain, link],
          price:       price }
      end
    end
  end
end