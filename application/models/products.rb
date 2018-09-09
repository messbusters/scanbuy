##
# The product model
#
# @author Emy <emy@messbusters.org>
##

require 'nokogiri'
require 'open-uri'
require 'uri'
require 'similar_text'

SIMILARITY_THRESHOLD = 5
USER_AGENT = 'Googlebot-Hackathon'

##
# The ScanBuy namespace
##
module ScanBuy

##
# Product model implementation
##
class Product

    # Search for products in emag
    def self.search_emag(term)
        ret = []
        begin
            doc = Nokogiri::HTML(open(URI.escape("https://www.emag.ro/search/#{term}"), 'User-Agent' => USER_AGENT))
            doc.search('#card_grid', '.card-item').each do |product|
                elem = {}

                # get image
                match = product.search('.card-heading img')
                next if match.length == 0
                elem[:image] = match.first.attr('src')

                # get title
                match = product.search('.product-title')
                next if match.length == 0
                elem[:title] = match.first.content
                next if elem[:title].similar(term) < SIMILARITY_THRESHOLD

                # get link
                elem[:url] = match.first.attr('href')

                # get price
                match = product.search('.product-new-price')
                next if match.length == 0
                price = match.first.content.split(' ')[0].gsub('.', '').to_f/100
                elem[:price] = "#{price} Lei"

                ret.push elem
            end
        rescue Exception => e
            puts "ERROR: #{e.message} #{e.backtrace}"
        end
        puts ret
        ret
    end

    # Search for products in amazon
    def self.search_amazon(term)
        ret = []
        begin
            doc = Nokogiri::HTML(open(URI.escape("https://www.amazon.co.uk/s?field-keywords=#{term}"), 'User-Agent' => USER_AGENT))
            doc.search('#atfResults', '.s-result-item').each do |product|
                elem = {}

                # get image
                match = product.search('a img')
                next if match.length == 0
                elem[:image] = match.first.attr('src')

                # get title
                match = product.search('.s-access-title')
                next if match.length == 0
                elem[:title] = match.first.content
                next if elem[:title].similar(term) < SIMILARITY_THRESHOLD

                # get link
                elem[:url] = match.first.parent.attr('href')

                # get price
                match = product.search('.s-price')
                next if match.length == 0
                elem[:price] = match.first.content

                ret.push elem
            end
        rescue Exception => e
            puts "ERROR: #{e.message} #{e.backtrace}"
        end
        puts ret
        ret
    end

    # Search for products in olx
    def self.search_olx(term)
        ret = []
        begin
            doc = Nokogiri::HTML(open(URI.escape("https://www.olx.ro/oferte/q-#{term.gsub(' ', '-')}/"), 'User-Agent' => USER_AGENT))
            doc.search('#offers_table', '.wrap').each do |product|
                elem = {}

                # get image
                match = product.search('a img')
                next if match.length == 0
                elem[:image] = match.first.attr('src')

                # get title
                match = product.search('.title-cell strong')
                next if match.length == 0
                elem[:title] = match.first.content
                next if elem[:title].similar(term) < SIMILARITY_THRESHOLD

                # get link
                elem[:url] = match.first.parent.attr('href')

                # get price
                match = product.search('.price strong')
                next if match.length == 0
                elem[:price] = match.first.content

                ret.push elem
            end
        rescue Exception => e
            puts "ERROR: #{e.message} #{e.backtrace}"
        end
        puts ret
        ret
    end

end # class Product

end # module ScanBuy
