require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'dotenv'
require 'aws/s3'

require 'json'
require 'securerandom'

# Establish database connection
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/commitphotos')

require File.expand_path('../lib/s3', __FILE__)

Dir.glob('./models/*.rb').each{ |m| require m }
