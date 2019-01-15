class Ticket < ActiveRecord::Base
  belongs_to :user

  enum status:{ TODO: 0, DOING: 1, DONE: 2}
  validates :title,
    presence: true,
    length: { maximum: 30 }
  validates :content,
    presence: true,
    length: { maximum: 1000 }
  validates :status,
    inclusion: { in: ['TODO','DOING', 'DONE'] }
end