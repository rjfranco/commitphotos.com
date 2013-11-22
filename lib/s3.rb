class S3
  # Upload a file to S3
  #
  # @param [String] name of file
  # @param [File] file to upload
  def self.upload(name, file)
    s3_connect
    AWS::S3::S3Object.store(name, file, ENV['AMAZON_BUCKET_NAME'], access: :public_read)
  end

  private  

  # Connect to S3 given propper environment variables.
  def self.s3_connect
    AWS::S3::Base.establish_connection!(
      access_key_id: ENV['AMAZON_ACCESS_KEY_ID'],
      secret_access_key: ENV['AMAZON_SECRET_ACCESS_KEY']
    )
  end

end