require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'dotenv'
require 'omniauth'
require 'omniauth-github'
require 'aws/s3'

require 'json'
require 'securerandom'

require File.expand_path('../lib/s3', __FILE__)

# Establish database connection
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/commitphotos')

use Rack::Session::Cookie, expire_after: 31556926,
                           key: 'commitphotos',
                           secret: ENV['SESSION_SECRET']

use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

Dir.glob('./models/*.rb').each{ |m| require m }