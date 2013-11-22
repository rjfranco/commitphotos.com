require './environment'

helpers do
  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end
end

get '/' do
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']
  user = User.find_by_github_id(auth['extra']['raw_info']['id']) || User.from_github(auth)
  session[:user_id] = user.id
  user.update_attributes(last_login: Time.now)
  redirect '/'
end

post '/photos/new' do
  if params['api_key'].nil?
    { success: false, error: "You need to provide an API key." }.to_json
  elsif user = User.find_by_api_key(params['api_key'])

    begin
      filename = params["photo"][:filename]
      S3.upload(filename, params["photo"][:tempfile])
      url = "http://#{ENV['AMAZON_BUCKET_NAME']}.s3.amazonaws.com/#{filename}"
    rescue "There was an error uploading the file"
    end

    photo = Photo.new
    photo.user_id = user.id
    photo.message = params['message']
    photo.url = url
    photo.save!

    "It worked"
  else
    { success: false, error: "An error occoured. Is your API key correct?" }.to_json
  end
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
