class User < ActiveRecord::Base

  has_many :photos

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

  def profile_photo
    hash = Digest::MD5.hexdigest(self.email).to_s
    "http://gravatar.com/avatar/#{hash}"
  end
end