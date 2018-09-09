##
# ScanBuy Sinatra extension
#
# @author Emy Carlan <emy@messbusters.org>
##

require 'sinatra/base'
require 'sinatra/json'
require 'slim'
require 'json'
require 'pp'

##
# The ScanBuy namespace
##
module ScanBuy

##
# The ScanBuy::Application extension
##
module Application

    # Create the various Sinatra filters when the extension gets registered.
    def self.registered(app)

        # Set template folder to views/index
        app.set :views, [
            File.expand_path('../views', __FILE__)
        ]

        # Configure hook
        app.configure do
            app.use Rack::Session::Cookie, :secret => '5c4n8uywithmessbusters', :expire_after => 2592000
            app.set :public_folder, File.expand_path('../public', File.dirname(__FILE__))
            app.set :show_exceptions, false
            app.set :raise_errors, false
        end

        # Log each request
        app.before do
            puts "#{request.request_method} #{request.fullpath} #{params.length} bytes"
        end # before filter

        # Catch all errors in the log and throw failwhale
        app.error do
            err = request.env['sinatra.error']
            puts "ERROR CRASH: #{err.message} #{err.backtrace.pretty_inspect}"
            slim :fail
        end

    end #registered

end # module Application

end # module ScanBuy
