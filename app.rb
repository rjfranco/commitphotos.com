require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'dotenv'
require 'omniauth'
require 'omniauth-github'

# Establish database connection
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/commitphotos')

class User
end

use Rack::Session::Cookie, expire_after: 31556926,
                           key: 'commitphotos',
                           secret: ENV['SESSION_SECRET']

use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

helpers do

  def current_user
    session[:user_id]
  end
end

get '/' do
  erb :index
end

get "/auth/github/callback" do
  auth = env['omniauth.auth']
  session[:user_id] = auth['extra']['raw_info']['id']
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
  redirect '/'
end
