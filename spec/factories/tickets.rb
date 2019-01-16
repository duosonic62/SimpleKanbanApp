FactoryBot.define do
  factory :todo_ticket, class: Ticket do
    title { "Todo title" }
    content { "Todo content" }
    status { "TODO" }
  end

  factory :doing_ticket, class: Ticket do
    title { "Doing title" }
    content { "Doing content" }
    status { "DING" }
    # association :user, factory: :user1
  end

  factory :done_ticket, class: Ticket do
    title { "Done title" }
    content { "Doing content" }
    status { "DONE" }
    # association :user, factory: :user1
  end
end