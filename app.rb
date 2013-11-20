require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'dotenv'
require 'omniauth'
require 'omniauth-github'

# Establish database connection
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/commitphotos')


use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

get '/' do
  erb :index
end

%w(get post).each do |method|
  send(method, "/auth/:provider/callback") do
    auth = env['omniauth.auth']
    p auth
    auth['extra']['raw_info']['name']
  end
end

get '/auth/failure' do
  flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
  redirect '/'
end