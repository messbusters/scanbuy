##
# Homepage controller
#
# @author Emy Carlan <emy@messbusters.org>
##

require 'sinatra/base'
require 'slim'
require 'pp'

LABEL_THRESHOLD = 0.92
OCR_THRESHOLD = 0.9
LOGO_THRESHOLD = 0.8
COLOR_COVERAGE = 0.1

# The ScanBuy module
module ScanBuy

    # Homepage controller implementation
    class IndexController < Sinatra::Base
        register ScanBuy::Application
        helpers ScanBuy::StringsHelper

        # Default route
        get '/' do
            slim :homepage
        end

        # Find products endpoint
        post '/find' do
            params['image'].gsub! /^data:image\/\w+;base64,/, ""
            blob = Base64.decode64(params['image'])

            # resize image, to allow the demo to work faster
            require 'mini_magick'
            image = MiniMagick::Image.read blob
            image.auto_orient
            image.resize "x800"

            # write image to file
            require 'securerandom'
            filename = "#{SecureRandom.uuid}.png"
            File.open("./tmp/#{filename}", 'wb') do |f|
                f.write image.to_blob
            end

            # run object detection
            resp = `GOOGLE_APPLICATION_CREDENTIALS=./config/google-creds.json php ./bin/vision.php ./tmp/#{filename}`
            resp = JSON.parse(resp)
            puts resp.pretty_inspect

            bag = []
            suffix_bag = []

            # get the dominant color
            if resp['colors'].length > 0
                color_hex = resp['colors'][0]
                if color_hex['fraction'] >= COLOR_COVERAGE
                    require 'color_namer'
                    bag.push ColorNamer.name_from_rgb(color_hex['red'], color_hex['green'], color_hex['blue'])[2].downcase
                end
            end

            # get the actual product found
            resp['labels'].each do |label|
                bag.push label['description'] if label['score'] >= LABEL_THRESHOLD
            end

            # check for OCR text
            resp['text_blocks'].each do |text|
                suffix_bag.push text['content'] if text['confidence'] >= OCR_THRESHOLD
            end if resp['text_blocks'].length > 0
            return json status: -1, error: 'Could not find what you are looking for. Sorry! :(' if bag.length == 0 && suffix_bag.length == 0

            en_keyword = bag.join(' ').split.uniq.join(' ')

            # translate to romanian
            ro_keyword = JSON.parse(`GOOGLE_APPLICATION_CREDENTIALS=./config/google-creds.json php ./bin/translate.php "#{en_keyword}"`)['to'] rescue en_keyword
            puts "KEYWORD RO: #{ro_keyword}"

            # add logo/brand if detected
            if resp['logos'].length > 0
                logo = resp['logos'][0]
                suffix_bag.push logo['description'] if logo['score'] >= LOGO_THRESHOLD
            end

            # cleanup and return string
            if suffix_bag.length > 0
                en_keyword = "#{suffix_bag.join(' ')} #{en_keyword}"
                ro_keyword = "#{suffix_bag.join(' ')} #{ro_keyword}"
            end
            `rm ./tmp/#{filename}`
            emag = ScanBuy::Product.search_emag ro_keyword
            amazon = ScanBuy::Product.search_amazon en_keyword
            olx = ScanBuy::Product.search_olx ro_keyword
            json status: 0, emag: emag, amazon: amazon, olx: olx, ro_keyword: ro_keyword, en_keyword: en_keyword
        end

    end # class IndexController

end # module ScanBuy
