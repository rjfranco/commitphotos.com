require 'dotenv'
# Load environment variables if we need to.
Dotenv.load('.env') unless ENV['RACK_ENV'] == 'production'

require './app'
run Sinatra::Application
