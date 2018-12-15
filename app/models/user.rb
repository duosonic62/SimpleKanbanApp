class User < ActiveRecord::Base
  has_secure_password validations: true
  validates :user_id, presence: true, uniqueness: true
end
