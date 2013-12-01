require 'rest-client'
 
api_key = '4a4182b092ffff1ac4a9'
filename = "#{Time.now.to_i}.jpg"
message = `git log -1 HEAD --pretty=format:%s`
 
begin
  `imagesnap -q -w 3 #{filename}`
  `convert #{filename} -resize '800x800>' #{filename}`
 
  RestClient.post('http://localhost:9393/photos/new', {
    "message" => message,
    "api_key" => api_key,
    'photo' => File.open('./' + filename)
    }
  )
 
  FileUtils.rm('./' + filename)
  exit 0
rescue => e
  puts "there was an error: #{e}"
  exit 1
end