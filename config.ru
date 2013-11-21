require 'dotenv'
# Load environment variables if we need to.
Dotenv.load('.env')

require './app'
run Sinatra::Application
