require './environment'

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
