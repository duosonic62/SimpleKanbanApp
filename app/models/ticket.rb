class Ticket < ActiveRecord::Base
  belongs_to :user

  enum status:{ TODO: 0, DOING: 1, DONE: 2}
end