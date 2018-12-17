class User < ActiveRecord::Base
  has_many :ticket

  has_secure_password validations: true
  validates :user_id, presence: true, uniqueness: true
  #validates :name, presence: true

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA256.hexdigest(token.to_s)
  end
end
