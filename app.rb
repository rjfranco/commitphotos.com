require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'dotenv'
require 'omniauth'
require 'omniauth-github'

require 'securerandom'

# Establish database connection
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/commitphotos')

class Photo < ActiveRecord::Base
end

class User < ActiveRecord::Base

  def self.from_github(auth)
    create do |user|
      user.github_token = auth['credentials']['token']
      user.github_id    = auth['uid']
      user.username     = auth['info']['nickname']
      user.api_key      = SecureRandom.hex(10)
      user.email        = auth['info']['email']
      user.name         = auth['info']['name'] || user.username
    end
  end

  def first_name
    self.name.split(' ')[0] || self.username
  end

end

use Rack::Session::Cookie, expire_after: 31556926,
                           key: 'commitphotos',
                           secret: ENV['SESSION_SECRET']

use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

helpers do
  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end
end

get '/' do
  erb :index
end

get "/auth/github/callback" do
  auth = env['omniauth.auth']
  user = User.find_by_github_id(auth['extra']['raw_info']['id']) || User.from_github(auth)
  session[:user_id] = user.id
  user.update_attributes(last_login: Time.now)
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/setup' do
  require_login
  erb :setup
end

get "/profiles/:username" do
  redirect '/404' unless @user = User.find_by_username(params[:username])
  erb :profile
end

def require_login
  redirect '/' unless current_user
end
