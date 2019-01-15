FactoryBot.define do
  factory :user1, class: User do
    user_id { "Taro" }
    name { "Yamada" }
    # password_digest "22619e7d79571adf0aab76bfcb725f8020532dfbe6d6c625698843f13b25ac58"
    password { 'passw0rd' }
    password_confirmation { 'passw0rd'}
    remember_token { User.new_remember_token }
  end

end