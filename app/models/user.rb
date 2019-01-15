class User < ActiveRecord::Base
  has_many :ticket

  validates :name, presence: true,length: { maximum: 10 }
  validates :user_id, presence: true, uniqueness: true,length: { maximum: 10 }
  has_secure_password validations: true

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA256.hexdigest(token.to_s)
  end
end
