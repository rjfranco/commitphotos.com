require './environment'

get '/' do
  @photos = Photo.where("photos.url IS NOT NULL").order("photos.created_at desc").limit(50)
  erb :index
end

post '/photos/new' do
  filename = params["photo"][:filename]
  S3.upload(filename, params["photo"][:tempfile])
  url = "http://#{ENV['AMAZON_BUCKET_NAME']}.s3.amazonaws.com/#{filename}"

  photo = Photo.new
  photo.message = params['message']
  photo.url = url
  photo.email = params["email"] if params["email"]
  photo.user_name = params["user_name"] if params["user_name"]
  photo.save! ? status(201) : status(500)
end