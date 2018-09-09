##
# Rack configuration file used to bootstrap the application
# @author Emy Carlan <emy@messbusters.org>
##

require 'sinatra/base'

# Pull in all controllers and helpers
require_relative './application/app.rb'
Dir.glob('./application/{models}/*.rb').each { |file| require file }
Dir.glob('./application/{helpers,controllers}/*.rb').each { |file| require file }

# Map web controllers to routes
map('/') { run ScanBuy::IndexController }
