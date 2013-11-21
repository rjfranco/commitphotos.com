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