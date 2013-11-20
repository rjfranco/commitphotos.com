require './app'

# Load environment variables if we need to.
Dotenv.load('.env')

run Sinatra::Application
